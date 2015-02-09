class Dashing.Versions extends Dashing.Widget

  ready: ->

  onData: (data) ->
    set_active("dev", data.dev_tomcat, data) 
    set_active("qa",data.qa_tomcat, data)
    set_active("ac1",data.ac1_tomcat, data)
    set_active("prod",data.prod_tomcat, data)


  set_active = (stage, active, data) -> 
    passive = "a"
    if active is "a"
      passive = "b"
    widget = $("[data-id=#{data.id}]") 

    $("[data-bind=#{stage}_#{active}]",  widget).parent().addClass('active')
    $("[data-bind=#{stage}_#{passive}]", widget).parent().removeClass('active')

    if data["#{stage}_#{active}"]? && data["#{stage}_#{active}"].indexOf('inc.') > -1
      $("[data-bind=#{stage}_#{active}]",  widget).parent().addClass('inconsistent')
    else
      $("[data-bind=#{stage}_#{active}]",  widget).parent().removeClass('inconsistent')
    if data["#{stage}_#{passive}"]? && data["#{stage}_#{passive}"].indexOf('inc.') > -1
      $("[data-bind=#{stage}_#{passive}]",  widget).parent().addClass('inconsistent')
    else
      $("[data-bind=#{stage}_#{passive}]",  widget).parent().removeClass('inconsistent')



