# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md
_arrival_prefix = "-arival-time"

changeArrivalTime = (user, newTime)->
    # TODO: Add parsing of 'newTime'
    @brain.set "#{user.name}#{_arrival_prefix}", user: user, time: newTime, created: new Date()
    return newTime

module.exports = (robot) ->

    robot.respond /(.+)\s*arrival time\s*(.*)?/i, (res)->
        patternMatches = res.match
        who = res.match[1]
        reply = ""
        if who.match /change|add|new|set/i
            if res.match.length > 2
                reply = changeArrivalTime.call robot, res.message.user, res.match[2]
                reply = "Cool, see you on #{reply}."
            else
                reply = "Sorry, but you have to tell me at what time you're going to arrive."
        else
            if who.match /my|mine|me/i
                who = res.message.user.name
                me = yes
            else
                me = no
            reply = robot.brain.get "#{who}#{_arrival_prefix}"
            if reply?
                if me?
                    who = "your"
                else
                    who += "'s"
                reply = "#{who} arrival time is #{reply.time}."
            else
                if me?
                    who = "you"
                reply = "It seems that `#{who}` didn't ask me to set arrival time yet."
        res.reply reply

    robot.router.get '/hubot/arrivaltime', (req, resp) ->
        console.log robot.brain.data
        res = []
        re = new RegExp ".+#{_arrival_prefix}"
        for key of robot.brain.data._private
            if key.match re
                obj = robot.brain.data._private[key]
                res.push {user: obj.user.name, time: obj.time, created: obj.created}
        resp.send JSON.stringify res

    robot.error (err, res) ->
      robot.logger.error "DOES NOT COMPUTE"

      if res?
        res.reply "DOES NOT COMPUTE"
