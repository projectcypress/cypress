module Cypress
  class ArtifactManager

    #Helper that stores files like PQRIs and associates them with a test execution
    def initialize(execution, test)
      db = Mongoid.database
      @grid = Mongo::Grid.new(db, fs_name='artifacts')
      @collection = db['artifacts.files']
      @test_name  = test.name
      @test_id  = test._id
      @execution_id   = execution._id
      @execution_time = execution.pretty_date.gsub('/', '-')
    end

    def save_artifacts(*artifacts)
      artifacts.each do |a|
        @grid.put(a, :filename => get_fname(a), :metadata => {'execution_id' => @execution_id, 'product_test_id' => @test_id})
      end
    end

    def del_execution_artifacts()
      artifacts = @collection.find(:metadata => {'execution_id' => @execution_id})
      artifacts.each do |a|
        @grid.delete(a['_id'])
      end
    end

    def del_test_artifacts
      artifacts = @collection.find(:metadata => {'product_test_id' => @test_id})
      artifacts.each do |a|
        @grid.delete(a['_id'])
      end
    end

    def del_artifact(artifact_id)
      @grid.delete(artifact_id)
    end

    private

    def get_fname(artifact)
      return 'pqri_test_'+ @test_name + "_"+ @execution_time +'.xml'
    end

  end
end