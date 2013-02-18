Campaings.Views.Campaings ||= {}

class Campaings.Views.Campaings.ShowView extends Backbone.View
  template: JST["backbone/templates/campaings/show"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
