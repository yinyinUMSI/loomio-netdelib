AppConfig   = require 'shared/services/app_config'
EventBus    = require 'shared/services/event_bus'
TimeService = require 'shared/services/time_service'
I18n        = require 'shared/services/i18n'

module.exports =
  props:
    zone:
      type: String
      default: AppConfig.timeZone
  data: ->
    dzone: @zone
  methods:
    names: ->
      _.uniq(_.values(AppConfig.timeZones)).sort()
    selectChanged: ->
      EventBus.emit @, 'timeZoneSelected', @dzone
  template:
    """
    <div class="time-zone-select">
      <div class="time-zone-select__change">
        <select md-select placeholder="Choose Timezone" v-model="dzone" :style="{ 'min-width': '10em' }" @change="selectChanged()">
          <option md-option :value="name" v-for="name in names()">{{name}}</option>
        </select>
        <!-- <md-item-template>
          <span>{{name}}</span>
        </md-item-template> -->
      </div>
    </div>
    """
