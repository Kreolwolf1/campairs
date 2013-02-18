Campaings.Views.Campaings ||= {}

class Campaings.Views.Campaings.IndexView extends Backbone.View
  template: JST["backbone/templates/campaings/index"]

  initialize: () ->
    @options.campaings.bind('reset', @addAll)

  addAll: () =>
    @options.campaings.each(@addOne)

  addOne: (campaing) =>
    view = new Campaings.Views.Campaings.CampaingView({model : campaing})
    @$("tbody").append(view.render().el)

  render: =>
    $(@el).html(@template(campaings: @options.campaings.toJSON() ))
    @addAll()

    return this
