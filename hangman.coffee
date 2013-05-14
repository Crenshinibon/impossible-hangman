alphabet = 'abcdefghijklmnopqrstuvwxyz'

if Meteor.isClient
    userData = new Meteor.Collection(null)
    id = userData.insert
        trials: 0
        misses: 0
        letters: []
        currentWord: 'NONE'
        dismissedWords: []
    
    getFirstWord = () ->
        wc = words.length
        randomIndex = Math.floor(Math.random() * wc)
        words[randomIndex]

    insertLetter = (letter) ->
        #the user inserted a new letter
        letterSeen = letter in userData.findOne({_id: id}).letters
        if /^[a-z]/.test(letter) and not letterSeen
            handleNewLetters(letter)
            userData.update {_id: id}, {$push: {letters: letter}}
            checkWon()
    
    checkWon = () ->
        fixedLetters = userData.findOne({_id: id}).letters
        cw = userData.findOne({_id: id}).currentWord
        won = true
        cw.split('').forEach (l) ->
            unless l in fixedLetters
                won = false
        if won
            canvas = document.getElementById 'canvas'
            ctx = canvas.getContext '2d'
            
            ctx.font = 'italic bold 42px Lucida, sans-serif'
            ctx.lineWidth = 2
            ctx.fillStyle = 'green'
            ctx.fillText('YOU WIN!', 0, 120)
            
            ctx.font = 'bold 24px Lucida, sans-serif'
            ctx.lineWidth = 2
            ctx.fillStyle = 'blue'
            ctx.fillText('Click to play again!', 10, 160)
    
    replaceWord = (cw, newLetter) ->
        fixedLetters = userData.findOne({_id: id}).letters
        
        fl = fixedLetters.reduce (s, l) -> s + l
        
        r = '^'
        cw.split('').map (l) ->
            if l in fixedLetters
                r += l + '{1}'
            else
                if fl.length is 0
                    r += '.{1}'
                else
                    r += '[^' + fl + ']{1}'
        r+= '$'
        r = new RegExp(r)
        
        mw = words.filter (w) ->
            r.test(w) and (w.indexOf newLetter) is -1
            
        if mw.length > 0
            userData.update {_id: id}, {$set: {currentWord: mw[0]}, $push: {dismissedWords: cw}}
            true
        else
            false
        
    
    handleNewLetters = (letter) ->
        cw = userData.findOne({_id: id}).currentWord
        if cw.indexOf(letter) is -1 or replaceWord(cw, letter)
            userData.update({_id: id}, {$inc: {misses: 1}})
            hangHim()
            
    
    hangHim = () ->
        missCount = userData.findOne({_id: id}).misses
        canvas = document.getElementById 'canvas'
        ctx = canvas.getContext '2d'
        
        if missCount is 1
            ctx.beginPath()
            ctx.lineCap = 'round'
            ctx.lineWidth = 10
            ctx.arc 60, 230, 50, Math.PI, 0
            ctx.stroke()
        
        if missCount is 2
            ctx.beginPath()
            ctx.lineWidth = 10
            ctx.moveTo(60,180)
            ctx.lineTo(60,20)
            ctx.stroke()
        
        if missCount is 3
            ctx.beginPath()
            ctx.lineWidth = 10
            ctx.moveTo(60,20)
            ctx.lineTo(200,20)
            ctx.stroke()
            
        if missCount is 4
            ctx.beginPath()
            ctx.lineWidth = 5
            ctx.moveTo(200,20)
            ctx.lineTo(200,50)
            ctx.stroke()
        
        if missCount is 5
            ctx.beginPath()
            ctx.lineWidth = 5
            ctx.arc 200, 70, 20, 2 * Math.PI, 0
            ctx.stroke()
        
        if missCount is 6
            ctx.beginPath()
            ctx.lineWidth = 10
            ctx.moveTo(200,95)
            ctx.lineTo(200,140)
            ctx.stroke()
            
        if missCount is 7
            ctx.beginPath()
            ctx.lineWidth = 4
            ctx.moveTo(205,95)
            ctx.lineTo(225,130)
            ctx.stroke()
            
        if missCount is 8
            ctx.beginPath()
            ctx.lineWidth = 4
            ctx.moveTo(195,95)
            ctx.lineTo(175,130)
            ctx.stroke()
        
        if missCount is 9
            ctx.beginPath()
            ctx.lineWidth = 6
            ctx.moveTo(195,140)
            ctx.lineTo(175,175)
            ctx.stroke()
        
        if missCount is 10
            ctx.beginPath()
            ctx.lineWidth = 6
            ctx.moveTo(205,140)
            ctx.lineTo(225,175)
            ctx.stroke()
            
            ctx.font = 'italic bold 48px Lucida, sans-serif'
            ctx.lineWidth = 2
            ctx.fillStyle = 'orange'
            ctx.fillText('YOU LOST', 0, 120)
            
            ctx.font = 'bold 24px Lucida, sans-serif'
            ctx.lineWidth = 2
            ctx.fillStyle = 'blue'
            ctx.fillText('Click to play again!', 10, 160)
            
        
        if missCount is 11
            ctx.strokeStyle = 'black'
            ctx.beginPath()
            ctx.lineWidth = 2
            ctx.moveTo(200,140)
            ctx.lineTo(200,155)
            ctx.stroke()
        
    
    Template.base.triedLetters = () ->
        userData.findOne({_id: id}).letters
        
    Template.base.fails = () ->
        userData.findOne({_id: id}).misses
    
    Template.base.currentWord = () ->
        cw = userData.findOne({_id: id}).currentWord
        if cw is 'NONE'
            cw = getFirstWord()
            userData.update({_id: id},{$set: {currentWord: cw}})
        cw
    
    Template.base.dismissedWords = () ->
        dm = userData.findOne({_id: id}).dismissedWords
        dm.map (w) ->
            {word: w}
    
    Template.base.events(
        'keyup input': (e, t) ->
            v = e.target.value
            if v.length is 1
                insertLetter(v)
            else if v.length > 1
                e.target.value = v[v.length - 1]
            e.target.select()
        'click canvas': (e, t) ->
            userData.remove({_id: id})
            id = userData.insert
                trials: 0
                misses: 0
                letters: []
                currentWord: 'NONE'
                dismissedWords: []
            e.target.getContext('2d').clearRect(0,0,250,250)
            
    )
    
    Template.word.letters = () ->
        out = []
        
        cw = userData.findOne({_id: id}).currentWord
        tl = userData.findOne({_id: id}).letters
        
        leading = Math.floor((12 - cw.length) / 2)
        letters = cw.split('')
        for i in [0...12]
            l = cw[i - leading]
            
            if l in tl
                out.push
                    letterClass: 'seen'
                    letter: l
            else if l?
                out.push
                    letterClass: 'unknown'
                    letter: '?'
            else
                out.push
                    letterClass: 'not-used'
                    letter: ''
            i++
            
        out