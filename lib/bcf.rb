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
      "e16e356f-5163-4df7-99da-78a98b90e180"
    when 2
      "bd6b1c70-142f-40f2-b7ba-9fbdc4042112"
    when 3
      "981604e1-0167-4a7d-8bbe-4c394f926a69"
    when 4
      "d6379389-b3aa-47c0-a48e-0f1ce6ecf40f"
    when 5
      "4ad024f9-e391-420e-868a-a65218747945"
    when 6
      "9ba95243-58ef-49d8-95a1-db5c525bf823"
    end
  end

  def viewpoint_xml(work_package)
    case work_package.done_ratio
    when 1
      viewpoint_0
    when 2
      viewpoint_1
    when 3
      viewpoint_2
    when 4
      viewpoint_3
    when 5
      viewpoint_4
    when 6
      viewpoint_5
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

  def viewpoint_1
<<~EOS
<?xml version="1.0" encoding="UTF-8"?>
<VisualizationInfo Guid="bd6b1c70-142f-40f2-b7ba-9fbdc4042112">
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
      <X>2571662.0833</X>
      <Y>5699368.628</Y>
      <Z>29.6069</Z>
    </CameraViewPoint>
    <CameraDirection>
      <X>0.735941147906526</X>
      <Y>-0.544461747198261</Y>
      <Z>-0.402432643626037</Z>
    </CameraDirection>
    <CameraUpVector>
      <X>0.323520532642385</X>
      <Y>-0.239345978897972</Y>
      <Z>0.915449598472881</Z>
    </CameraUpVector>
    <FieldOfView>60</FieldOfView>
  </PerspectiveCamera>
</VisualizationInfo>
EOS
  end

  def viewpoint_2
<<~EOS
<?xml version="1.0" encoding="UTF-8"?>
<VisualizationInfo Guid="981604e1-0167-4a7d-8bbe-4c394f926a69">
  <Components>
    <Visibility DefaultVisibility="false">
      <Exceptions>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$b">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fe5</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$_">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ffe</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$Z">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fe3</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$X">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fe1</AuthoringToolId>
        </Component>
        <Component IfcGuid="32w5cNmLbCh8w$GVP1xvba">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>c2e85997-c159-4cac-8ebf-41f641ef9964</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_V">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f9f</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_R">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f9b</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_N">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f97</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_M">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f96</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_P">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f99</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_L">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f95</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_K">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f94</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_J">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f93</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_I">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f92</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_H">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f91</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_G">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f90</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$7">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fc7</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$z">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ffd</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$6">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fc6</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$y">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ffc</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$5">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fc5</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$x">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ffb</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$w">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ffa</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$4">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fc4</AuthoringToolId>
        </Component>
        <Component IfcGuid="2u6vkv7458fRtCstpnZ59g">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>b81b9bb9-1c41-48a5-bdcc-db7cf18c526a</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXPzz">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f7d</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$t">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ff7</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXPzy">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f7c</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$0">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fc0</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$r">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ff5</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$p">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ff3</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$n">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ff1</AuthoringToolId>
        </Component>
        <Component IfcGuid="0MwFvYQlTBd8MOHvqn2_eU">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>{16e8fe62-6af7-4b9c-8598-479d310bea1e}</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$l">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fef</AuthoringToolId>
        </Component>
        <Component IfcGuid="2L5QAs$LXD8P8Uc2PwaGvp">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>9515a2b6-fd58-4d21-921e-98267a910e73</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXPzp">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f73</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$j">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fed</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXPzo">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f72</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXPzn">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f71</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$h">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859feb</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$$">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fff</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$f">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fe9</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$d">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fe7</AuthoringToolId>
        </Component>
      </Exceptions>
    </Visibility>
  </Components>
  <PerspectiveCamera>
    <CameraViewPoint>
      <X>2571688.5888</X>
      <Y>5699314.1612</Y>
      <Z>27.1839</Z>
    </CameraViewPoint>
    <CameraDirection>
      <X>-0.0187529636892105</X>
      <Y>0.879112922078115</Y>
      <Z>-0.476244471451532</Z>
    </CameraDirection>
    <CameraUpVector>
      <X>-0.0101567884681524</X>
      <Y>0.476136153044654</Y>
      <Z>0.879312915526578</Z>
    </CameraUpVector>
    <FieldOfView>60</FieldOfView>
  </PerspectiveCamera>
</VisualizationInfo>
EOS
  end

  def viewpoint_3
<<~EOS
<?xml version="1.0" encoding="UTF-8"?>
<VisualizationInfo Guid="d6379389-b3aa-47c0-a48e-0f1ce6ecf40f">
  <Components>
    <Visibility DefaultVisibility="false">
      <Exceptions>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlQQ">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f69a</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlRz">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f6fd</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlRy">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f6fc</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlRx">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f6fb</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlRw">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f6fa</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlRv">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f6f9</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlRu">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f6f8</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlRt">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f6f7</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlU_">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f7be</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlQN">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f697</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlQM">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f696</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlRr">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f6f5</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlQL">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f695</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlRq">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f6f4</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlQK">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f694</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlUv">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f7b9</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlQJ">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f693</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlQI">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f692</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlQH">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f691</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlQG">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f690</AuthoringToolId>
        </Component>
        <Component IfcGuid="000VyBiebE$gM5OP_ZqlUq">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0001ff0b-b289-4efe-a585-619fa3d2f7b4</AuthoringToolId>
        </Component>
      </Exceptions>
    </Visibility>
  </Components>
  <PerspectiveCamera>
    <CameraViewPoint>
      <X>2571677.7567</X>
      <Y>5699313.2351</Y>
      <Z>36.3593</Z>
    </CameraViewPoint>
    <CameraDirection>
      <X>0.201288673706641</X>
      <Y>0.933977973609043</Y>
      <Z>-0.295242298207027</Z>
    </CameraDirection>
    <CameraUpVector>
      <X>0.0622017338947177</X>
      <Y>0.288615590277202</Y>
      <Z>0.95542241199871</Z>
    </CameraUpVector>
    <FieldOfView>60</FieldOfView>
  </PerspectiveCamera>
</VisualizationInfo>
EOS
  end

  def viewpoint_4
<<~EOS
<?xml version="1.0" encoding="UTF-8"?>
<VisualizationInfo Guid="4ad024f9-e391-420e-868a-a65218747945">
  <Components>
    <Visibility DefaultVisibility="false">
      <Exceptions>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$b">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fe5</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$_">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ffe</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$Z">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fe3</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$X">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fe1</AuthoringToolId>
        </Component>
        <Component IfcGuid="32w5cNmLbCh8w$GVP1xvba">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>c2e85997-c159-4cac-8ebf-41f641ef9964</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_V">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f9f</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_R">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f9b</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_N">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f97</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_M">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f96</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_P">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f99</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_L">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f95</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_K">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f94</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_J">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f93</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_I">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f92</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_H">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f91</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP_G">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f90</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$7">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fc7</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$z">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ffd</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$6">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fc6</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$y">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ffc</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$5">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fc5</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$x">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ffb</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$w">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ffa</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$4">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fc4</AuthoringToolId>
        </Component>
        <Component IfcGuid="2u6vkv7458fRtCstpnZ59g">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>b81b9bb9-1c41-48a5-bdcc-db7cf18c526a</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXPzz">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f7d</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$t">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ff7</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXPzy">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f7c</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$0">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fc0</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$r">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ff5</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$p">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ff3</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$n">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859ff1</AuthoringToolId>
        </Component>
        <Component IfcGuid="0MwFvYQlTBd8MOHvqn2_eU">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>{16e8fe62-6af7-4b9c-8598-479d310bea1e}</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$l">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fef</AuthoringToolId>
        </Component>
        <Component IfcGuid="2L5QAs$LXD8P8Uc2PwaGvp">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>9515a2b6-fd58-4d21-921e-98267a910e73</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXPzp">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f73</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$j">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fed</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXPzo">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f72</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXPzn">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859f71</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$h">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859feb</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$$">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fff</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$f">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fe9</AuthoringToolId>
        </Component>
        <Component IfcGuid="0QBiFqEIP1tQ5Ob0vsXP$d">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>1a2ec3f4-3926-41dd-a158-940e76859fe7</AuthoringToolId>
        </Component>
      </Exceptions>
    </Visibility>
  </Components>
  <PerspectiveCamera>
    <CameraViewPoint>
      <X>2571688.5888</X>
      <Y>5699314.1612</Y>
      <Z>27.1839</Z>
    </CameraViewPoint>
    <CameraDirection>
      <X>-0.0187529636892105</X>
      <Y>0.879112922078115</Y>
      <Z>-0.476244471451532</Z>
    </CameraDirection>
    <CameraUpVector>
      <X>-0.0101567884681524</X>
      <Y>0.476136153044654</Y>
      <Z>0.879312915526578</Z>
    </CameraUpVector>
    <FieldOfView>60</FieldOfView>
  </PerspectiveCamera>
</VisualizationInfo>
EOS
  end

  def viewpoint_5
<<~EOS
<?xml version="1.0" encoding="UTF-8"?>
<VisualizationInfo Guid="9ba95243-58ef-49d8-95a1-db5c525bf823">
  <Components>
    <Visibility DefaultVisibility="true">
      <Exceptions>
        <Component IfcGuid="0FWCbj_RL0ew20jSwNVi8C">
          <OriginatingSystem>DESITE</OriginatingSystem>
          <AuthoringToolId>0f80c96d-f9b5-40a3-a080-b5ce977ec20c</AuthoringToolId>
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
      <X>2571619.6293</X>
      <Y>5699421.9478</Y>
      <Z>60.3762</Z>
    </CameraViewPoint>
    <CameraDirection>
      <X>0.735941116822247</X>
      <Y>-0.544461470447363</Y>
      <Z>-0.402433074894099</Z>
    </CameraDirection>
    <CameraUpVector>
      <X>0.323520932679286</X>
      <Y>-0.239346163301283</Y>
      <Z>0.915449408886849</Z>
    </CameraUpVector>
    <FieldOfView>60</FieldOfView>
  </PerspectiveCamera>
</VisualizationInfo>
EOS
  end
end
