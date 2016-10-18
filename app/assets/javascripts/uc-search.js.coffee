this.showOrHideSearchInput = ->
  column_name = $(this).attr('name').slice(7)
  column = $('#' + column_name)
  container = $('#' + column_name + '_container')

  if container.hasClass('hidden')
    container.removeClass('hidden')
  else
    column.val('')
    container.addClass('hidden')

this.showOrHideSearchInputWithValue = (defaultValue) ->
  column_name = $(this).attr('name').slice(7)
  column = $('#' + column_name)
  container = $('#' + column_name + '_container')

  if container.hasClass('hidden')
    column.val(defaultValue)
    container.removeClass('hidden')
  else
    column.val('')
    container.addClass('hidden')

this.reverseSort = (orderField) ->
  if orderField.endsWith('_asc')
    $('#orderBy').val(orderField.replace('_asc', '_desc'))
  else
    $('#orderBy').val(orderField.replace('_desc', '_asc'))

this.unitedAgentIdChanged = ->
  if $(this).prop('checked')
    $('#united').val('agent_id')
  else
    $('#united').val('')