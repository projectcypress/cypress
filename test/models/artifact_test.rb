require 'test_helper'
class ArtifactTest < ActiveSupport::TestCase
  def test_should_be_able_to_tell_if_a_file_is_an_archive
    filename = Rails.root.join('test', 'fixtures', 'artifacts', 'qrda.zip')
    artifact = Artifact.new(file: File.new(filename))

    assert artifact.archive?, 'should be able to tell it is an archive'
  end

  def test_should_be_able_to_read_file_from_archive
    expected = ['eh_test_results_bad.xml', 'eh_test_results.xml', 'qrda_cat3.xml', 'QRDA_CATIII_RI_AUG.xml']
    filename = Rails.root.join('test', 'fixtures', 'artifacts', 'qrda.zip')
    artifact = Artifact.new(file: File.new(filename))
    expected.each do |n|
      assert artifact.get_file(n)
    end
  end

  def test_should_be_able_to_list_file_names
    expected = ['eh_test_results_bad.xml', 'eh_test_results.xml', 'qrda_cat3.xml', 'QRDA_CATIII_RI_AUG.xml',
                'expected_results.json']
    filename = Rails.root.join('test', 'fixtures', 'artifacts', 'qrda.zip')
    artifact = Artifact.new(file: File.new(filename))
    assert_equal expected.sort, artifact.file_names.sort

    root = Rails.root.join('tmp', 'test', 'artifacts')
    FileUtils.mkdir_p(root)
    filename = "#{root}/good_file_extension.xml"
    FileUtils.touch(filename)

    expected = ['good_file_extension.xml']
    artifact = Artifact.new(file: File.new(filename))
    assert_equal expected, artifact.file_names
  end

  def test_should_be_able_to_give_file_count_for_archive
    filename = Rails.root.join('test', 'fixtures', 'artifacts', 'qrda.zip')
    artifact = Artifact.new(file: File.new(filename))
    assert_equal 5, artifact.file_count
  end

  def test_should_be_able_to_give_file_count_single_file
    root = Rails.root.join('tmp', 'test', 'artifacts')
    FileUtils.mkdir_p(root)
    filename = "#{root}/good_file_extension.xml"
    FileUtils.touch(filename)
    artifact = Artifact.new(file: File.new(filename))
    assert_equal 1, artifact.file_count
  end

  def test_should_be_able_to_loop_over_archive_files
    expected = ['eh_test_results_bad.xml', 'eh_test_results.xml', 'qrda_cat3.xml', 'QRDA_CATIII_RI_AUG.xml']
    reported = {}
    filename = Rails.root.join('test', 'fixtures', 'artifacts', 'qrda.zip')
    artifact = Artifact.new(file: File.new(filename))
    artifact.each_file do |name, data|
      reported[name] = data
    end
    assert_equal expected.sort, reported.keys.sort, 'Archive should contain the correct files'
  end

  def test_should_be_able_to_loop_on_single_file
    root = Rails.root.join('tmp', 'test', 'artifacts')
    FileUtils.mkdir_p(root)
    filename = "#{root}/good_file_extension.xml"
    FileUtils.touch(filename)

    expected = ['good_file_extension.xml']
    reported = {}
    artifact = Artifact.new(file: File.new(filename))
    artifact.each_file do |name, data|
      reported[name] = data
    end
    assert_equal expected, reported.keys, 'Should loop on single xml document'
  end

  def test_should_be_able_to_ge_t_contents_for_a_given_file_name_in_an_archive
    filename = Rails.root.join('test', 'fixtures', 'artifacts', 'qrda.zip')
    artifact = Artifact.new(file: File.new(filename))
    data = artifact.get_archived_file('expected_results.json')
    # look at the first bit of the file data coming back and see if it matches what should be read
    assert data.index(%!{ "_id" : ObjectId( "507885343054cf8d83000002" )!).zero?, 'should be able to read file from archive'
  end

  def test_c1_task_should_accept_zip_files_not_xml_files
    task = C1Task.new
    zip_execution = task.test_executions.build
    xml_execution = task.test_executions.build
    root = Rails.root.join('tmp', 'test', 'artifacts')
    FileUtils.mkdir_p(root)

    zip_filename = "#{root}/good_file_extension.zip"
    xml_filename = "#{root}/good_file_extension.xml"
    FileUtils.touch(zip_filename)
    FileUtils.touch(xml_filename)
    zip_artifact = Artifact.new(file: File.new(zip_filename))
    xml_artifact = Artifact.new(file: File.new(xml_filename))
    xml_artifact.file.file.content_type = 'text/xml'
    zip_artifact.test_execution = zip_execution
    xml_artifact.test_execution = xml_execution

    assert zip_artifact.save, 'C1 execution artifact should save with .zip extension'
    assert_not xml_artifact.save, 'C1 execution artifact should not save with .xml extension'
  end

  def test_c2_task_should_accept_xml_files_not_zip_files
    task = C2Task.new
    zip_execution = task.test_executions.build
    xml_execution = task.test_executions.build
    root = Rails.root.join('tmp', 'test', 'artifacts')
    FileUtils.mkdir_p(root)

    zip_filename = "#{root}/good_file_extension.zip"
    xml_filename = "#{root}/good_file_extension.xml"
    FileUtils.touch(zip_filename)
    FileUtils.touch(xml_filename)
    zip_artifact = Artifact.new(file: File.new(zip_filename))
    xml_artifact = Artifact.new(file: File.new(xml_filename))
    xml_artifact.file.file.content_type = 'text/xml'
    zip_artifact.test_execution = zip_execution
    xml_artifact.test_execution = xml_execution

    assert_not zip_artifact.save, 'C2 execution artifact should not save with .zip extension'
    assert xml_artifact.save, 'C2 execution artifact should save with .xml extension'
  end

  def test_should_not_except_non_xml_or_zip_files
    root = Rails.root.join('tmp', 'test', 'artifacts')
    FileUtils.mkdir_p(root)

    # generate a random set of bad file extensions and try to save
    10.times do
      ext = rand(36**3).to_s(36)
      next unless %w[zip xml].index(ext)

      filename = "#{root}/bad_file_extension.#{ext}"
      FileUtils.touch(filename)
      artifact = Artifact.new(file: File.new(filename))
      assert_not artifact.save, "File should not save with un whitelisted extension #{ext}"
    end

    FileUtils.rm_rf(root)
  end
end
