(function() {
    for (var i = 0; i < testLoopCount; ++i) {
        var o = {};
        
        if (hasCustomProperties(o))
            throw "Error: object shouldn't have custom properties yet.";
        
        o.f = 42;
        
        if (!hasCustomProperties(o))
            throw "Error: object should have custom properties already.";
    }
})();
