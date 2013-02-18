Campaings.Views.Campaings ||= {}

class Campaings.Views.Campaings.CampaingView extends Backbone.View
  template: JST["backbone/templates/campaings/campaing"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
