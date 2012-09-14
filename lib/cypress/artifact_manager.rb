module Cypress
  class ArtifactManager

    #Helper that stores files like PQRIs and associates them with a test execution
    def self.grid()
        @@grid ||=  Mongo::Grid.new(Mongoid.database, fs_name='artifacts')
    end

    def self.save_artifacts(*artifacts, test_execution)

      ids = []
      artifacts.each do |a|
       ids << grid.put(a.read, :filename => File.basename(a.path), :metadata => {'execution_id' => test_execution.id, 'product_test_id' => test_execution.product_test_id})
      end
      ids
    end

    def self.del_artifacts(test_execution)
      artifacts = @collection.find(:metadata => {'execution_id' => test_execution.id})
      artifacts.each do |a|
        grid.delete(a['_id'])
      end
    end

    def self.del_artifact(artifact_id)
      grid.delete(artifact_id)
    end

  end
end