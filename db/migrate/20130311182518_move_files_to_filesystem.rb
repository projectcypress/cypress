class MoveFilesToFilesystem < Mongoid::Migration
 
 def self.up
		TestExecution.where({}).each do |te|
			if te.files && !te.files.empty?
					
					file = te.files[0]
					root = "tmp/migration/#{te.id}"
					FileUtils.mkdir_p(root)
					tmp = File.open("#{root}/results.xml", "w") do |f|
						f.puts file.data.force_encoding("UTF-8")
					end

					artifact = Artifact.new(file: File.new("#{root}/results.xml"), test_execution: te)
				  artifact.save
					te.artifact = artifact
					te.execution_errors.each do |ee| 
						ee[:file_name] = "results.xml"
						ee.save
					end
					te.save
				  puts "File for  test execution #{te.id} moved to #{artifact.file.path}"
			end
		end
  end


  def self.down
  end

end