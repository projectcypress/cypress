class NotesController < ApplicationController
  layout nil
  
  
  def delete
     test = ProductTest.find(params[:test_id])
     note = test.notes.find(params[:note][:id])
     note.destroy

     redirect_to :action => 'show', :execution_id => params[:execution_id]
   end

   def create
     test = ProductTest.find(params[:test_id])

     note = Note.new(params[:note])
     note.time = Time.now.gm

     test.notes << note
     test.save!
     redirect_to :action => 'show', :execution_id => params[:execution_id]
   end
  
end