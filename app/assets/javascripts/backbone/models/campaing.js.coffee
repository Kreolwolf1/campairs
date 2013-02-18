class Campaings.Models.Campaing extends Backbone.Model
  paramRoot: 'campaing'

  defaults:
    name: null
    start_at: null
    end_at: null
    countries: null

class Campaings.Collections.CampaingsCollection extends Backbone.Collection
  model: Campaings.Models.Campaing
  url: '/campaings'
