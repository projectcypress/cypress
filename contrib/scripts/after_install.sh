#!/bin/bash

SKIP_SETTINGS_CREATE=true cypress run rake db:mongoid:create_indexes
