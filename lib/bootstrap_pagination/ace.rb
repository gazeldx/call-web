require 'will_paginate/view_helpers/action_view'

module BootstrapPagination
  # A custom renderer class for WillPaginate that produces markup suitable for use with Twitter Bootstrap.
  class Ace < WillPaginate::ActionView::LinkRenderer
    include BootstrapRenderer
  end
end