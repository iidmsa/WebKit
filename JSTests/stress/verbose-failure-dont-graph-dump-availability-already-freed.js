//@ runDefault("--verboseValidationFailure=true")

function foo() {
    arguments.length;
}
let a = 0;
for (var i = 0; i < testLoopCount; i++) {
    a += foo();
}
