require 'rack'
require './middlewares/actionkiq'

use Rack::Reloader
run Middlewares::Actionkiq
