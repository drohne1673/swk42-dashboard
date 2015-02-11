require 'net/http'
require 'json'
require 'time'

JENKINS_PATH_1 = "http://thisisajenkins.somedomain/jenkins"
JENKINS_PATH_2 = "http://thisisanotherjenkins.somedomain/jenkins"

JENKINS_AUTH = {
    'name' => nil,
    'password' => nil
}

# the key of this mapping must be a unique identifier for your job, the according value must be the name that is specified in jenkins
job_mapping = {
    'widgetname1' => {:job => 'jobtitle1', :jenkins_host => JENKINS_PATH_1},
    'widgetname2' => {:job => 'jobtitle2', :jenkins_host => JENKINS_PATH_2}
}

def get_number_of_failing_tests(job_name, jenkins_host)
  info = get_json_for_job(job_name, jenkins_host, 'lastCompletedBuild')
  info['actions'][4]['failCount']
end

def get_completion_percentage(job_name, jenkins_host)
  build_info = get_json_for_job(job_name, jenkins_host)
  prev_build_info = get_json_for_job(job_name, jenkins_host, 'lastCompletedBuild')

  return 0 if not build_info['building']
  last_duration = (prev_build_info['duration'] / 1000).round(2)
  current_duration = (Time.now.to_f - build_info['timestamp'] / 1000).round(2)
  return 99 if current_duration >= last_duration
  ((current_duration * 100) / last_duration).round(0)
end

def get_json_for_job(job_name, jenkins_host, build = 'lastBuild')
  job_name = URI.encode(job_name)
  jenkins_path = jenkins_host

  uri = URI.parse(jenkins_path + "/job/#{job_name}/#{build}/api/json")
  response = Net::HTTP.get_response(uri)
  if response.is_a?(Net::HTTPNotFound)
    return JSON.parse(%q[
                {
                "actions": [],
                "building": false,
                "description": null,
                "result": "NOTFOUND",
                "number" : 1337
                }
               ])
  end
  JSON.parse(response.body)
end

def get_short_description_for_action(actions)
  return 'no cause found' if actions.empty?
  actions.each {
      |action| return action['causes'][0]['shortDescription'] if action.has_key?('causes')
  }
end

def dontDoAthing
  job_mapping.each do |title, jenkins_project|
    current_status = nil
    SCHEDULER.every '10s', :first_in => 0 do |job|
      last_status = current_status
      build_info = get_json_for_job(jenkins_project[:job], jenkins_project[:jenkins_host])
      current_status = build_info['result']
      short_description = ''
      percent=0
      if build_info['building']
        current_status = 'BUILDING'
        percent = get_completion_percentage(jenkins_project[:job], jenkins_project[:jenkins_host])
        short_description = ": " + get_short_description_for_action(build_info['actions'])
      elsif jenkins_project[:pre_job]
        pre_build_info = get_json_for_job(jenkins_project[:pre_job], jenkins_project[:jenkins_host])
        current_status = 'PREBUILD' if pre_build_info['building']
        percent = get_completion_percentage(jenkins_project[:pre_job], jenkins_project[:jenkins_host])
      end

      send_event title, {
                          :currentResult => current_status,
                          :lastResult => last_status,
                          :timestamp => build_info['timestamp'],
                          :value => percent,
                          :number => '#'+build_info['number'].to_s+short_description,
                          :title => title
                      }
    end
  end

end