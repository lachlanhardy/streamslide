$(document).ready(function(){
  // making sexy unobtrusive CSS possible since 2006
	$("html").addClass("js");
	
    var slideshow = [];
	$('ul li a img').each(function() {
        slideshow.push({ src: this.src, href: $(this).parents("a").attr("href") });
    });
	
	$("ul").crossSlide({
           sleep: 2,
           fade: 1
       }, 
       slideshow
    );
	
	
    // $('#test3').crossSlide({
    //       fade: 1
    //     }, [
    //       {
    //         src:  'lib/sand-castle.jpeg',
    //         from: '100% 80% 1x',
    //         to:   '100% 0% 1.7x',
    //         time: 3
    //       }, {
    //         src:  'lib/sunflower.jpeg',
    //         from: 'top left',
    //         to:   'bottom right 1.5x',
    //         time: 2
    //       }, {
    //         src:  'lib/flip-flops.jpeg',
    //         from: '100% 80% 1.5x',
    //         to:   '80% 0% 1.1x',
    //         time: 2
    //       }, {
    //         src:  'lib/rubber-ring.jpeg',
    //         from: '100% 50%',
    //         to:   '30% 50% 1.5x',
    //         time: 2
    //       }
    //     ]);
});