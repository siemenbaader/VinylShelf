require.config (
	shim :
		'underscore' : { exports: '_' }
		'backbone' : {
			exports : 'Backbone' 
			deps    : ['underscore']
		}
)

require ['jquery', 'underscore', 'backbone'], ($, _,  Backbone ) ->

	Album = Backbone.Model.extend()
	Track = Backbone.Model.extend()
	
	Player = Backbone.Model.extend(

		initialize: () ->
			@audio = $('<audio>')[0]

			notifying_playlist = []
			_.extend(notifying_playlist, Backbone.Events)
			old_push = notifying_playlist.push
			notifying_playlist.push = (item) ->
				old_push.apply this, [item]
				this.trigger 'add'

			notifying_playlist.get = (key) -> return this[key]
			notifying_playlist.clear = ()->
				this.length = 0
				this.trigger('change')

			@playlist = notifying_playlist
			

		play: (tracks) ->
			@audio.pause()
			@playlist.clear()

			@enqueue tracks
			
			@audio.src = '../Music/' + tracks[0].get('audio_url')
			@set('current_track', tracks[0])
			@playlist.trigger('change')
			@trigger('change')
			@audio.play()

		enqueue: (tracks) ->
			_(tracks).each (track) =>
				@playlist.push track

 		
		play_pause: () ->
			if @audio.paused then @audio.play() else @audio.pause()
	)


	player = new Player()

	PlayerView = Backbone.View.extend(

		initialize: (player)->
			@player = player
			@player.playlist.on('all', this.render, this)

		tagName: 'div'

		className: 'player'

		events:
			'mouseenter .playlist' : ()-> $('body').css("overflow", "hidden")
			'mouseleave .playlist' : ()-> $('body').css("overflow", "auto")
			'click .play-pause'    : ()-> @player.play_pause()

		render: ()->

			@$el.html """
				<div class='playlist'><ol> #{ 
					_(@player.playlist).map( (track) -> 

						if @player.get('current_track') == track
							open_tag = "<li class='playing'>"
						else
							open_tag = "<li>"

						open_tag + "#{ track.get('title') } </li>"
					).join("\n")
				} </ol></div>
				<div class='play-pause'></div>
				<div class='current-track'>
					<h1 class='title'>Dickens Dublin</h1>
					<h2 class='artist'>Loreena McKinnet</h2>
				</div>
				<div class='elapsed'>1:25 / 3:17</div>
			"""
	)

	ApplicationView = Backbone.View.extend(
		
		el: $('body')
		
		events: 
			'keydown': (ev) -> 
				console.log 'play-pause'; 
				if ev.keyCode == 32 then player.play_pause(); ev.preventDefault()
	

		initialize: (albums) ->
			@albums = albums

		render: () ->

			_(@albums).each (album)=>
		
				view = new AlbumView {model: album}

				view.render()
				@$el.append view.el

			player_view = new PlayerView(player)
			player_view.render()
			@$el.append player_view.el
	)
	

	TrackView = Backbone.View.extend(
		tagName: 'li'

		events :
			"click .play-button" : () ->
				player.play [this.model]
			"click .enqueue-button" : () ->
				player.enqueue [this.model]

		initialize: () -> 
			@render()
			player.on 'all', ()=>
				@render()
		
		render: ()->
			this.$el.html """
				<div class='title'>#{this.model.get('title')}</div>
				#{ if player.get('current_track') is this.model then '<div class="now-playing"></div>' else '' }
				<div class='play-button'> &gt; </div>
				<div class='enqueue-button'> = </div>
				<div class='duration-spacer'></div>
				<div class='duration'>4:43</div>
			"""
	)

	AlbumView = Backbone.View.extend(

		events: 
			"click .album-cover .play-button" : () -> 
				player.play @model.get('tracks')


			"click .album-cover .enqueue-button" : () -> 
				player.enqueue @model.get('tracks')
		

		render: ()->
			this.$el.html """
				<div class='album'>
					<div class='album-cover'>
						<img class='cover-art' src='#{ this.model.get('cover_art') }'>

						<div class='play-button'><span>&gt;</span></div>
						<div class='enqueue-button'><span>=</span></div>
					</div>

					<div class='album-details'>
						<h1>#{ this.model.get('title') }</h1>
						<h2>#{ this.model.get('artist') }</h2>
						<ol></ol>
					</div>
				</div>
			"""
			_(this.model.get('tracks')).each (track) =>
				tv = new TrackView(model:track)
				this.$el.find('ol').append( tv.el )
	)



	albums = [ 
		new Album(
			title     : "Begin To Hope"
			artist    : "Regina Spektor"
			cover_art : "http://ecx.images-amazon.com/images/I/51oIoQcHKBL._SL500_AA300_.jpg"
			tracks    : [
				new Track(
					title : 'Fidelity'
					audio_url: "Regina Spektor/Begin To Hope/01 Fidelity.mp3"
				)
				new Track(
					title : 'Better'
					audio_url: "Regina Spektor/Begin To Hope/02 Better.mp3"
				)
				new Track(
					title: "Samson"
					audio_url: "Regina Spektor/Begin To Hope/03 Samson.mp3"
				)
				new Track(
					title: "On The Radio"
					audio_url: "Regina Spektor/Begin To Hope/04 On The Radio.mp3"
				)
				new Track(
					title: "Field Below"
					audio_url: "Regina Spektor/Begin To Hope/05 Field Below.mp3"
				)
				new Track(
					title: "Hotel Song"
					audio_url: "Regina Spektor/Begin To Hope/06 Hotel Song.mp3"
				)
				new Track(
					title: "Apres Moi"
					audio_url: "Regina Spektor/Begin To Hope/07 Apres Moi.mp3"
				)
				new Track(
					title: "20 Years Of Snow"
					audio_url: "Regina Spektor/Begin To Hope/08 20 Years Of Snow.mp3"
				)
				new Track(
					title: "That Time"
					audio_url: "Regina Spektor/Begin To Hope/09 That Time.mp3"
				)
				new Track(
					title: "Edit"
					audio_url: "Regina Spektor/Begin To Hope/10 Edit.mp3"
				)
				new Track(
					title: "Lady"
					audio_url: "Regina Spektor/Begin To Hope/11 Lady.mp3"
				)
				new Track(
					title: "Summer In The City"
					audio_url: "Regina Spektor/Begin To Hope/12 Summer In The City.mp3"
				)
			]
		)
		new Album(
			title     : "Parallel Dreams"
			artist    : "Loreena McKennitt"
			cover_art : "http://1.bp.blogspot.com/_ZoPAJf0WQP8/TUx8sPteokI/AAAAAAAAAGI/D8_94yY_eaI/s1600/Loreena+MckennittParallel+dreams1989.jpg"
			tracks    : [
				new Track(
					title : "Samain Night"
					audio_url: "Loreena McKennitt/Parallel Dreams/01 - Samain Night.mp3"
				)
				new Track(
					title : "Moon Cradle"
					audio_url: "Loreena McKennitt/Parallel Dreams/02 - Moon Cradle.mp3"
				)
				new Track(
					title : "Huron 'Beltane' Fire Dance"
					audio_url: "Loreena McKennitt/Parallel Dreams/03 - Huron 'Beltane' Fire Dance.mp3"
				)
				new Track(
					title : "Annachie Gordon"
					audio_url: "Loreena McKennitt/Parallel Dreams/04 - Annachie Gordon.mp3"
				)
				new Track(
					title : "Standing Stones"
					audio_url: "Loreena McKennitt/Parallel Dreams/05 - Standing Stones.mp3"
				)
				new Track(
					title : "Dickens' Dublin"
					audio_url: "Loreena McKennitt/Parallel Dreams/06 - Dickens' Dublin.mp3"
				)
				new Track(
					title : "Breaking The Silence"
					audio_url: "Loreena McKennitt/Parallel Dreams/07 - Breaking The Silence.mp3"
				)
				new Track(
					title : "Ancient Pines"
					audio_url: "Loreena McKennitt/Parallel Dreams/08 - Ancient Pines.mp3"
				)
			]
		)
		new Album(
			title     : "Nattog Til Venus"
			artist    : "Anne Linnet"
			cover_art : "http://www.stereostudio.dk/media/catalog/product/cache/1/image/9df78eab33525d08d6e5fb8d27136e95/a/n/anne-linnet-nattog-til-venus.jpg"
			tracks    : [
				new Track(
					title : "Barndommens Gade"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 01 - Barndommens Gade.mp3"
				)
				new Track(
					title : "De Evige Tre"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 02 - De Evige Tre.mp3"
				)
				new Track(
					title : "Time Og Dag Og Uge"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 03 - Time Og Dag Og Uge.mp3"
				)
				new Track(
					title : "Mild, Lattermild Og Gavmild"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 04 - Mild, Lattermild Og Gavmild.mp3"
				)
				new Track(
					title : "Levende Hænder"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 05 - Levende Hænder.mp3"
				)
				new Track(
					title : "Lille Messias"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 06 - Lille Messias.mp3"
				)
				new Track(
					title : "Tusind Stykker"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 07 - Tusind Stykker.mp3"
				)
				new Track(
					title : "Forårsdag"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 08 - Forårsdag.mp3"
				)
				new Track(
					title : "Tabt Mit Hjerte"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 09 - Tabt Mit Hjerte.mp3"
				)
				new Track(
					title : "Søndag I April"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 10 - Søndag I April.mp3"
				)
				new Track(
					title : "Blinkende Lygter"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 11 - Blinkende Lygter.mp3"
				)
				new Track(
					title : "Smuk Og Dejlig"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 12 - Smuk Og Dejlig.mp3"
				)
				new Track(
					title : "Måne Sol Og Stjerner"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 13 - Måne Sol Og Stjerner.mp3"
				)
				new Track(
					title : "Cha Cha Cha"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 14 - Cha Cha Cha.mp3"
				)
				new Track(
					title : "Laila"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 15 - Laila.mp3"
				)
				new Track(
					title : "I Dag Er du Star"
					audio_url: "Nattog Til Venus; De Bedst, Disc 2/Anne Linnet - 16 - I Dag Er du Star.mp3"
				)
			]
		)
	
	]

	player.set( 'current_track', albums[0].get('tracks')[2])

	window.player = player
	application_view = new ApplicationView( albums )
	application_view.render()










