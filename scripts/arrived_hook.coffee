# Module handles incomming post request to notify chanel users that someone's came.
module.exports = (robot) ->
    robot.router.post "/hubot/arrived/:username", (req, resp)->
        message = ""
        if !req.params.username
            resp.send "Fail! No username..."
        if req.params.username is "unknown"
            message = "Some stranger just came into the office..."
        else
            message = "Look who's back! Seems that @#{req.params.username} just came into the office."
        robot.messageRoom "#general_omsk", message
        resp.send "OK"
