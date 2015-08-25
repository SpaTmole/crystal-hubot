# Module handles incomming post request to notify chanel users that someone's came.
module.exports = (robot) ->
    robot.router.post "/hubot/arrived/:username", (req, resp)->
        message = ""
        console.log req.headers, req.body, req.params
        if req.headers and token = req.headers['authorization']
            if token isnt process.env.HUBOT_SLACK_TOKEN
                resp.send "Unauthorized"
                return
            ct = req.headers["content-type"]
            if !ct or !ct.length or !ct.match /json/gi
                resp.send "Cannot process non JSON request."
                return
            if !req.params.username or !req.body.room
                resp.send "Failed. Not enough params..."
                return
            room = req.body.room
            if req.params.username is "unknown"
                message = "Some stranger just came into the office..."
            else
                if !robot.brain.userForName req.params.username
                    resp.send "Failed. No such user."
                    return
                message = "Look who's back! Seems that @#{req.params.username} just came into the office."
            if !robot.adapter.client.getChannelGroupOrDMByName(room) and !robot.brain.userForName room
                resp.send "Failed. No such room."
                return
            robot.messageRoom room, message
            resp.send "OK"
        else
            resp.send "Failed. No authorization header."
