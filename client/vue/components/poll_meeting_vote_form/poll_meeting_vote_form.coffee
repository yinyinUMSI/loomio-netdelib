EventBus = require 'shared/services/event_bus'

{ submitOnEnter } = require 'shared/helpers/keyboard'
{ submitStance }  = require 'shared/helpers/form'
{ buttonStyle }   = require 'shared/helpers/style'

module.exports =
  props:
    stance: Object
  data: ->
    vars: {}
    zone: null
    stanceValuesMap: _.fromPairs _.map @stance.poll().pollOptions(), (option) =>
      stanceChoice = @stance.stanceChoices().find((sc) => sc.pollOptionId == option.id) or {}
      [option.id, stanceChoice.score or 0]
    canRespondMaybe: @stance.poll().customFields.can_respond_maybe
    stanceValues: if @stance.poll().customFields.can_respond_maybe then [2,1,0] else [2, 0]
  created: ->
    EventBus.listen @, 'timeZoneSelected', (e, zone) =>
      @zone = zone
  mounted: ->
    submitOnEnter @, element: @$el
  methods:
    selectedColor: (option, score) ->
      buttonStyle(score == @stanceValuesMap[option.id])

    click: (optionId, score)->
      @stanceValuesMap[optionId] = score

    orderedPollOptions: ->
      _.sortBy @stance.poll().pollOptions(), 'name'

    # submit = submitStance $scope, $scope.stance,
    #   prepareFn: ->
    #     EventBus.emit $scope, 'processing'
    #     $scope.stance.id = null
    #     attrs = _.compact _.map(_.toPairs($scope.stanceValuesMap), ([id, score]) ->
    #         {poll_option_id: id, score:score} if score > 0
    #     )
    #
    #     $scope.stance.stanceChoicesAttributes = attrs if _.some(attrs)
  template:
    """
    <form @submit.prevent="submit()" class="poll-meeting-vote-form">
      <h3 v-t="'poll_meeting_vote_form.your_response'" class="lmo-card-subheading lmo-flex__grow"></h3>
      <ul md-list class="poll-common-vote-form__options">
        <li md-list-item class="lmo-flex--row lmo-flex__horizontal-center lmo-flex__center">
          <h3 v-t="'poll_meeting_vote_form.can_attend'" class="lmo-h3 poll-meeting-vote-form--box"></h3>
          <h3 v-t="'poll_meeting_vote_form.if_need_be'" v-if="canRespondMaybe" class="lmo-h3 poll-meeting-vote-form--box"></h3>
          <h3 v-t="'poll_meeting_vote_form.unable'" class="lmo-h3 poll-meeting-vote-form--box"></h3>
          <time-zone-select class="lmo-margin-left"></time-zone-select>
        </li>
        <li md-list-item v-for="option in orderedPollOptions()" :key="option.id" class="poll-common-vote-form__option lmo-flex--row">
          <button md-colors="selectedColor(option, i)" v-for="i in stanceValues" @click="click(option.id, i)" class="poll-meeting-vote-form--box">
            <img src="/img/agree.svg" v-if="i == 2" class="poll-common-form__icon">
            <img src="/img/abstain.svg" v-if="i == 1" class="poll-common-form__icon">
            <img src="/img/disagree.svg" v-if="i == 0" class="poll-common-form__icon">
          </button>
          <poll-meeting-time :name="option.name" :zone="zone" class="lmo-margin-left"></poll-meeting-time>
        </li>
      </ul>
      <validation-errors :subject="stance" field="stanceChoices"></validation-errors>
      <poll-common-stance-reason :stance="stance"></poll-common-stance-reason>
      <div class="poll-common-form-actions lmo-flex lmo-flex__space-between">
        <poll-common-show-results-button v-if="stance.isNew()"></poll-common-show-results-button>
        <div v-if="!stance.isNew()"></div>
        <button type="submit" v-t="'poll_common.vote'" aria-label=" $t('poll_meeting_vote_form.vote')" class="md-primary md-raised poll-common-vote-form__submit"></button>
      </div>
    </form>
    """
