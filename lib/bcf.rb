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

      if guid = viewpoint_guid(wp)
        vp_file = "#{dir}/#{work_package_guid(wp)}/viewpoint.bcfv"

        File.open(vp_file, "w") do |f|
          f.write viewpoint_xml(wp)
        end

        snapshot_file = "#{dir}/#{work_package_guid(wp)}/snapshot.png"
        FileUtils.cp Rails.root.join("config/locales/media/snapshot_#{wp.done_ratio}.png").to_s, snapshot_file

        files << vp_file
        files << snapshot_file
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

        if vp_guid = viewpoint_guid(work_package)
          xml.Viewpoints "Guid" => vp_guid do
            xml.Viewpoint "viewpoint-#{work_package.done_ratio}.bcfv"
            xml.Snapshot "snapshot.png"
          end
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

      if vp_guid = viewpoint_guid(work_package)
        xml.Viewpoint "Guid" => vp_guid
      end
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

  def viewpoint_guid(work_package)
    case work_package.done_ratio
    when 1
      viewpoint_0_guid
    end
  end

  def viewpoint_xml(work_package)
    case work_package.done_ratio
    when 1
      viewpoint_0
    end
  end

  def viewpoint_0_guid
    "e16e356f-5163-4df7-99da-78a98b90e180"
  end

  def viewpoint_0
<<~EOS
<?xml version="1.0" encoding="UTF-8"?>
<VisualizationInfo Guid="e16e356f-5163-4df7-99da-78a98b90e180">
  <Components>
    <Visibility DefaultVisibility="true">
      <Exceptions>
        <Component IfcGuid="0FWCbj_RL0ew20jSwNVi8C">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0f80c96d-f9b5-40a3-a080-b5ce977ec20c</AuthoringToolId>
        </Component>
        <Component IfcGuid="2u6vkv7458fRtCstpnZ4gd">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>b81b9bb9-1c41-48a5-bdcc-db7cf18c4aa7</AuthoringToolId>
        </Component>
        <Component IfcGuid="3JI4uv9zb6_9yGKsONOeam">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>{d3484e39-27d9-46f8-9f10-536617628930}</AuthoringToolId>
        </Component>
        <Component IfcGuid="1oCJIVjSn4Q9mOBftr$Nwa">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>{7231349f-b5cc-4468-9c18-2e9df5fd7ea4}</AuthoringToolId>
        </Component>
        <Component IfcGuid="32w5cNmLbCh8w$GVP1xxuj">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>c2e85997-c159-4cac-8ebf-41f641efbe2d</AuthoringToolId>
        </Component>
      </Exceptions>
    </Visibility>
  </Components>
  <PerspectiveCamera>
    <CameraViewPoint>
      <X>2571665.9677</X>
      <Y>5699360.3707</Y>
      <Z>22.5621</Z>
    </CameraViewPoint>
    <CameraDirection>
      <X>0.91588950168981</X>
      <Y>-0.246883457755875</Y>
      <Z>-0.316535904726295</Z>
    </CameraDirection>
    <CameraUpVector>
      <X>0.305627095453685</X>
      <Y>-0.082383599735861</Y>
      <Z>0.94858052953827</Z>
    </CameraUpVector>
    <FieldOfView>60</FieldOfView>
  </PerspectiveCamera>
</VisualizationInfo>
EOS
  end
end
