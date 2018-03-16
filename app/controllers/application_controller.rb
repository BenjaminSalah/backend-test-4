require 'twilio-ruby'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def index
    @calls = Call.all
  end

  def answer
    calls_id = params[:CallSid]
    caller_num = params[:Caller]
    call = Call.create(callsid: calls_id, caller: caller_num)
    call.save

    response = Twilio::TwiML::VoiceResponse.new do |r|
      gather = Twilio::TwiML::Gather.new(num_digits: '1', action: menu_path)
      gather.say('Press 1 to forward your call. Press 2 to leave a voicemail')
      r.append(gather)
    end

    render xml: response.to_s
  end

  def menu
    user_selection = params[:Digits]

    case user_selection
    when '1'
      response = Twilio::TwiML::VoiceResponse.new
      response.dial do |dial|
        dial.number('+16469370240', status_callback_event: 'initiated ringing answered completed', status_callback: status_url, status_callback_method: 'POST')
      end
    when '2'
      response = Twilio::TwiML::VoiceResponse.new
      response.say('Hello. Please leave a message after the beep.')
      response.record(timeout: 10, action: recording_done_path, recording_status_callback: recording_path, recording_status_callback_method: 'POST')
    else
      response = Twilio::TwiML::VoiceResponse.new do |r|
        r.redirect(answer_path)
      end
    end
    render xml: response.to_s
  end

  def status
    calls_id = params[:ParentCallSid]
    call = Call.find_by(callsid: calls_id)

    if !call
      head :not_found
    else
      called_num = params[:Called]
      status = params[:CallStatus]
      call_duration = params[:CallDuration]

      call.update_attributes(called: called_num, status: status, duration: call_duration)
      head :ok, content_type: 'text/html'
    end
  end

  def recording
    calls_id = params[:CallSid]
    call = Call.find_by(callsid: calls_id)

    if !call
      head :not_found
    else
      call_duration = params[:RecordingDuration]
      recording_url = params[:RecordingUrl]
      call.update_attributes(duration: call_duration, url: recording_url)
      head :ok, content_type: 'text/html'
    end
  end

  def recording_done
    response = Twilio::TwiML::VoiceResponse.new do |r|
      r.say("Goodbye!")
      r.hangup
    end

    calls_id = params[:CallSid]
    call = Call.find_by(callsid: calls_id)

    if !call
      head :not_found
    else
      caller_num = params[:To]
      status = params[:CallStatus]
      call.update_attributes(called: caller_num, status: status)
    end
    head :ok, content_type: 'text/html'
  end
end
