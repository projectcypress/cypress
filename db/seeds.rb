# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
    given_name:
    family_name: 
    title: 
    addresses: [{street: '', city: '', state: zip: '', country: '', use: ''} ]
    telecoms: [{use: '',  value: '', preffered: true}]
    organization: 
       name:
       addresses: [{street: city: state: zip: country: use:} ]
       telecoms: [{use: '',  value: '', preffered: true}]
    cda_identifiers: [{root: '2.16.840.1.113883.4.6'  extension: ''}, #npi
                      {root: '2.16.840.1.113883.4.2']  extension: ''} #tin
                     ]

