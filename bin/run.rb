#!/usr/bin/env ruby

require 'pry'
require_relative '../config/environment'

def reset_database
  Dog.drop_table
  Dog.create_table
end

reset_database

binding.pry
"pls"