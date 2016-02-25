class MeasureTest < ProductTest
  validate :at_most_one_measure?

  def at_most_one_measure?
    errors.add(:measure_ids, 'MeasureTest must have a single measure id') if measure_ids.length != 1
  end

  after_create do |product_test|
    product_test.queued
    ProductTestSetupJob.perform_later(product_test)
    create_tasks
  end

  # only creates c1, c2, and c3 tasks with no attributes as of now ~ JaeBird
  # as of now, should only create one task per task type
  def create_tasks
    product_c1_and_c2_if_only_c3(product)
    if product.c1_test
      C1Task.new(product_test: self).save!
      C3Cat1Task.new(product_test: self).save! if product.c3_test
    end
    if product.c2_test
      C2Task.new(product_test: self).save!
      C3Cat3Task.new(product_test: self).save! if product.c3_test
    end
  end

  def archive_records
    file = Tempfile.new("product_test-#{id}.zip")
    recs = records.to_a

    if product.duplicate_records
      ids = results.where('value.IPP' => { '$gt' => 0 }).collect { |pc| pc.value.patient_id }
      unless ids.nil? || ids.empty?
        dups = Record.find(ids)
        (rand(3) + 1).times do
          recs << dups.sample
        end
      end
    end
    Cypress::PatientZipper.zip(file, recs, :qrda)
    self.patient_archive = file
    save
  end

  def product_c1_and_c2_if_only_c3(product)
    if product.c3_test && !product.c1_test && !product.c2_test
      product.c1_test = true
      product.c2_test = true
    end
  end
end
