require 'tmpdir'
require 'zip'

module BCF
  module_function

  def create_bcf_file!(file_name:, work_packages:)
    dir = Dir.mktmpdir
    manifest_file = "#{dir}/bcf.version"
    files = [manifest_file]

    File.open(manifest_file, "w") do |f|
      f.write manifest.to_xml
    end

    work_packages.each_with_index do |wp, i|
      path = "#{dir}/#{work_package_guid(wp)}"
      Dir.mkdir path

      file = "#{path}/markup.bcf"

      File.open(file, "w") do |f|
        f.write work_package(wp, index: i).to_xml
      end

      files << file
    end

    file_name = "#{file_name}.bcfzip" unless file_name.end_with?(".bcfzip")
    zip_file = "#{dir}/#{file_name}"

    Zip::File.open(zip_file, Zip::File::CREATE) do |zipfile|
      files.each do |file|
        name = file.sub("#{dir}/", "")

        zipfile.add name, file
      end
    end

    container = work_packages.first.project.wiki.pages.where(title: "Wiki").first!

    Attachment.create!(
      author: User.current,
      container: container,
      content_type: "application/octet-stream",
      file: File.new(zip_file)
    )
  ensure
    FileUtils.rm_rf dir
  end

  def manifest
    Nokogiri::XML::Builder.new do |xml|
      xml.comment created_by_comment
      xml.Version "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema", "VersionId" => "2.1" do
        xml.DetailedVersion "2.1"
      end
    end
  end

  def work_package(work_package, index: nil)
    Nokogiri::XML::Builder.new do |xml|
      xml.comment created_by_comment
      xml.Markup "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema" do
        topic xml, work_package, index

        work_package.journals.reject { |j| j.notes.empty? }.each do |journal|
          comment xml, journal, work_package
        end
      end
    end
  end

  def topic(xml, work_package, index)
    xml.Topic "Guid" => work_package_guid(work_package), "TopicType" => work_package.type.name, "TopicStatus" => work_package.status.name do
      xml.Title work_package.subject
      xml.Index index if index
      xml.CreationDate format_date_time(work_package.created_at)
      xml.ModifiedDate format_date_time(work_package.updated_at)
      xml.CreationAuthor work_package.author.mail
      xml.Description work_package.description
    end
  end

  def comment(xml, journal, work_package)
    xml.Comment "Guid" => comment_guid(journal) do
      xml.Date format_date_time(journal.created_at)
      xml.Author work_package.author.mail
      xml.Comment journal.notes
    end
  end

  def topic_xml(xml, work_package)
    xml.Version "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema", "VersionId" => "2.1" do
      xml.DetailedVersion "2.1"
    end
  end

  def work_package_guid(work_package)
    work_package.custom_field_values.each do |value|
      return value.value if value.custom_field.name == "GUID"
    end

    work_package.id
  end

  def comment_guid(journal)
    journal.id
  end

  def created_by_comment
    " Created by OpenProject #{OpenProject::VERSION} at #{DateTime.now} "
  end

  def format_date_time(date_time)
    date_time.utc.strftime "%Y-%m-%dT%H:%M:%SZ"
  end
end
