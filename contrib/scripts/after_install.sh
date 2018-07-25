#!/bin/bash

SKIP_SETTINGS_CREATE=true cypress run rake db:migrate db:mongoid:create_indexes
