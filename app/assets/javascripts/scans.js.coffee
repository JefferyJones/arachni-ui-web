# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

scan_type_selected = false

pickScanType = ( type ) ->
    $('#grid-alert').show( 50 )

    scan_type_selected = true

    switch type
        when 'direct'
            $('#scan_type').val( 'direct' )

            $('#dispatcher-grid').hide( 50 )
            $('#dispatcher-remote').hide( 50 )
            $('#direct').show
        when 'remote'
            $('#scan_type').val( 'remote' )

            $('#direct').hide( 50 )
            $('#dispatcher-grid').hide( 50 )
            $('#dispatcher-remote').show( 50 )
        when 'grid'
            $('#scan_type').val( 'grid' )

            $('#direct').hide( 50 )
            $('#dispatcher-remote').hide( 50 )
            $('#dispatcher-grid').show( 50 )

window.scanTableLoading = () ->
    $('#loading').show()

window.hookDescriptionFormButtons = () ->
    $('#edit-description-btn').click ->
        $('#scan-description').hide()
        $('#edit-description-btn').hide()
        $('#scan-description-form').show()

    $('.edit_scan').on 'submit', () ->
        $('#posting-form-spinner').show()

jQuery ->
    $('#direct-btn').click ->
        pickScanType( 'direct' )
    $('#remote-btn').click ->
        pickScanType( 'remote' )
    $('#grid-btn').click ->
        pickScanType( 'grid' )
    $('#add-scan-comment').on 'shown', () ->
        $('textarea#comment_text').focus()
    $('#active-scan-counter').bind 'refreshed', () ->
        if $(this).text() == '0'
            $(this).hide()
        else
            $(this).show()
    $('#direct-btn').click()
    window.hookDescriptionFormButtons()


