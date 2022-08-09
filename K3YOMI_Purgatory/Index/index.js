// This basically just shows the countdown timer...
window.addEventListener('message', (event) => {
    if (event.data.type === 'open') {
        $('.container').show();
        $(function() {
            var otherHeight = $(".container2").outerHeight(true);
            $(window).resize(function() {
                $('#frame').height( $(window).height() - otherHeight );
            }).resize();
        });
        $( '#frame' ).attr( 'src', function ( i, val ) { return val; });
        var seconds = event.data.seconds;
        var reason = event.data.reason;
        var sentBY = event.data.staff;
        document.getElementById('reason').innerHTML = "STAFF MEMBER: " + sentBY + "<br>REASON SPECIFED : " +reason;
        loop = setInterval(function(){ 
            seconds--;
            $('.seconds').text(seconds);
            if (seconds <= 0) {
                clearInterval(loop);
                fetch(`https://${GetParentResourceName()}/_CloseRules`, {
                    method: 'POST'
                }).then(resp => resp.json()).then(resp => console.log(resp));
            }
        }, 1000);

    }
    
    if (event.data.type === 'close') {
        $('.container').hide();
        clearInterval(loop);
    }
});
