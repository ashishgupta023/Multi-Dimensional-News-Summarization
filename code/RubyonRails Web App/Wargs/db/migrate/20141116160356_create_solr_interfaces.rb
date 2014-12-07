class CreateSolrInterfaces < ActiveRecord::Migration
  def change
    create_table :solr_interfaces do |t|

      t.timestamps
    end
  end
end
