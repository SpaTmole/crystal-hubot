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
    decodeTime = (query) ->
        # Returns array [Hours, Minutes] or null
        hours = minutes = 0
        if time = query.match /\d?\d([\-|\:][0-5]\d)?\s*[p|a]\.?\s*m/i
            match = time[0].match(/\d?\d/g)
            console.log match
            hours = Number(match[0])
            if match.length > 1
                minutes = Number(match[1])
            else
                minutes = 0
            if hours <= 12 and hours >= 1
                if time[0].match /a\.?\s*m/i
                    if hours is 12
                        hours = 0
                else if time[0].match /p\.?\s*m/
                    if hours isnt 12
                        hours += 12
                else
                    return null
            else
                return null
            return [hours, minutes]
        else if time = query.match /[0-2]?\d\:[0-5]\d/
            time = time[0].split ":"
            hours = Number(time[0])
            minutes = Number(time[1])
            if hours > 23
                return null
            return [hours, minutes]
        else
            return null

    decodeDate = (query)->
        # Return [Year, Month, Day]
        days = ['sunday','monday','tuesday','wednesday','thursday','friday','saturday']
        today = new Date()
        day = year = month = 0
        if date = query.match /tomorrow|today/i
            day = today.getDate()
            month = today.getMonth()
            year = today.getFullYear()
            if date[0] is "tomorrow"
                day += 1
            return [year, month, day]
        else if date = query.match /[0-3]?\d[\.|\-|\/][0-1]\d([\.|\/|\-]\d{2,4})?/
            # Here we suppose that date format is day%month%year
            date = date[0]
            if date.split('.').length > 1
                date = date.split '.'
            else if date.split('-').length > 1
                date = date.split '-'
            else if date.split('/').length > 1
                date = date.split '/'
            else
                return null
            day = Number(date[0])
            month = Number(date[1]) - 1
            if month < 0
                return null
            if date.length > 2
                year = date[2]
            else
                year = today.getFullYear()
                if month < today.getMonth() or (month is today.getMonth() and date < today.getDate())
                    year += 1
            return [year, month, day]
        else if date = query.match new RegExp days.join("|"), "i"
            month = today.getMonth()
            year = today.getFullYear()
            day = today.getDate() + Math.abs today.getDay() - days.indexOf date[0].toLowerCase()
            return [year, month, day]
        else
            day = today.getDate()
            month = today.getMonth()
            year = today.getFullYear()
            return [year, month, day]

    newDate = decodeDate newTime
    if !newDate
        return null
    newTime = decodeTime newTime
    if !newTime
        return null
    newTime = new Date newDate[0], newDate[1], newDate[2], newTime[0], newTime[1] - (new Date()).getTimezoneOffset(), 0
    newTime = newTime.toISOString().split('.')[0]
    @brain.set "#{user.name}#{_arrival_prefix}", user: user, time: newTime, created: new Date()
    return newTime.replace 'T', ' '

module.exports = (robot) ->

    robot.respond /(.+)\s*arrival time\s*(.*)?/i, (res)->
        patternMatches = res.match
        who = res.match[1]
        if !who.length
            res.reply "Eh?"
            return
        reply = ""
        if who.match /change|add|new|set/i
            if res.match.length > 2
                reply = changeArrivalTime.call robot, res.message.user, res.match[2]
                if reply is null
                    reply = "Sorry, i'm too stupid to get `#{res.match[2]}` :( Will you give me another chance?"
                else
                    reply = "Cool, see you on #{reply}."
            else
                reply = "Sorry, but you have to tell me at what time you're going to arrive."
        else if who.match /all|everyone|staff|whole/i
            reply = "Here you go:\n"
            re = new RegExp ".+#{_arrival_prefix}"
            for key of robot.brain.data._private
                if key.match re
                    obj = robot.brain.data._private[key]
                    reply += "#{obj.user.name} arrives on #{obj.time.replace "T", ' '}; was set on #{obj.created}\n"
            if reply is "Here you go:\n"
                reply = "Sorry mate, nobody set their time yet."
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
