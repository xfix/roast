use v6;

use Test;

plan 129;

=begin pod

Class attributes tests from L<S12/Attributes>

=end pod

eval_dies_ok 'has $.x;', "'has' only works inside of class|role definitions";

# L<S12/Attributes/the automatic generation of an accessor method of the same name>

class Foo1 { has $.bar; };

{
    my $foo = Foo1.new();
    ok($foo ~~ Foo1, '... our Foo1 instance was created');
    my $val;
    #?pugs 2 todo 'feature'
    lives_ok {
        $val = $foo.can("bar")
    }, '.. checking autogenerated accessor existence';
    ok($val, '... $foo.can("bar") should have returned true');
    ok($foo.bar().notdef, '.. autogenerated accessor works');
    ok($foo.bar.notdef, '.. autogenerated accessor works w/out parens');    
}

# L<S12/Attributes/Pseudo-assignment to an attribute declaration specifies the default>

{
    class Foo2 { has $.bar = "baz"; };
    my $foo = Foo2.new();
    ok($foo ~~ Foo2, '... our Foo2 instance was created');
    ok($foo.can("bar"), '.. checking autogenerated accessor existence');
    is($foo.bar(), "baz", '.. autogenerated accessor works');
    is($foo.bar, "baz", '.. autogenerated accessor works w/out parens');
    dies_ok { $foo.bar = 'blubb' }, 'attributes are ro by default';
}

# L<S12/Attributes/making it an lvalue method>


#?pugs todo 'instance attributes'
{
    class Foo3 { has $.bar is rw; };
    my $foo = Foo3.new();
    ok($foo ~~ Foo3, '... our Foo3 instance was created');
    my $val;
    lives_ok {
        $val = $foo.can("bar");
    }, '.. checking autogenerated accessor existence';
    ok $val, '... $foo.can("bar") should have returned true';
    ok($foo.bar().notdef, '.. autogenerated accessor works');
    lives_ok {
        $foo.bar = "baz";
    }, '.. autogenerated mutator as lvalue works';
    is($foo.bar, "baz", '.. autogenerated mutator as lvalue set the value correctly');    
}

# L<S12/Attributes/Private attributes use an exclamation to indicate that no public accessor is>


{
    class Foo4 { has $!bar; };
    my $foo = Foo4.new();
    ok($foo ~~ Foo4, '... our Foo4 instance was created');
    #?pugs eval 'todo'
    ok(!$foo.can("bar"), '.. checking autogenerated accessor existence', );
}


{
    class Foo4a { has $!bar = "baz"; };
    my $foo = Foo4a.new();
    ok($foo ~~ Foo4a, '... our Foo4a instance was created');
    #?pugs eval 'todo'
    ok(!$foo.can("bar"), '.. checking autogenerated accessor existence');
}


# L<S12/Attributes>


{
    class Foo5 {
        has $.tail is rw;
        has @.legs;
        has $!brain;

        method set_legs  (*@legs) { @.legs = @legs }
        method inc_brain ()      { $!brain++ }
        method get_brain ()      { $!brain }
    };
    my $foo = Foo5.new();
    ok($foo ~~ Foo5, '... our Foo5 instance was created');
        
    lives_ok {
        $foo.tail = "a";
    }, "setting a public rw attribute";
    is($foo.tail, "a", "getting a public rw attribute");
    
    #?rakudo 2 todo 'oo'
    lives_ok { $foo.set_legs(1,2,3) }, "setting a public ro attribute (1)";
    is($foo.legs.[1], 2, "getting a public ro attribute (1)");
    
    dies_ok {
        $foo.legs = (4,5,6);
    }, "setting a public ro attribute (2)";
    #?rakudo todo 'oo'
    is($foo.legs.[1], 2, "getting a public ro attribute (2)");
    
    lives_ok { $foo.inc_brain(); }, "modifiying a private attribute (1)";
    is($foo.get_brain, 1, "getting a private attribute (1)");
    lives_ok {
        $foo.inc_brain();
    },  "modifiying a private attribute (2)";
    is($foo.get_brain, 2, "getting a private attribute (2)");
}

# L<S12/Construction and Initialization/If you name an attribute as a parameter, that attribute is initialized directly, so>


{
    class Foo6 {
        has $.bar is rw;
        has $.baz is rw;
        has $!hidden;

        submethod BUILD($.bar, $.baz, $!hidden) {}
        method get_hidden() { $!hidden }
    }

    my $foo = Foo6.new(bar => 1, baz => 2, hidden => 3);
    ok($foo ~~ Foo6, '... our Foo6 instance was created');
        
    is($foo.bar,        1, "getting a public rw attribute (1)"  );
    is($foo.baz,        2, "getting a public ro attribute (2)"  );
    is($foo.get_hidden, 3, "getting a private ro attribute (3)" );
}

# check that doing something in submethod BUILD works

{
    class Foo6a {
        has $.bar is rw;
        has $.baz is rw;
        has $!hidden;

        submethod BUILD ($!hidden, $.bar = 10, $.baz?) {
            $.baz = 5;
        }
        method get_hidden() { $!hidden }
    }

    my $foo = Foo6a.new(bar => 1, hidden => 3);
    ok($foo ~~ Foo6a, '... our Foo6a instance was created');
        
    is($foo.bar,        1, "getting a public rw attribute (1)"  );
    is($foo.baz,        5, "getting a public rw attribute (2)"  );
    is($foo.get_hidden, 3, "getting a private ro attribute (3)" );
}

# check that assignment in submethod BUILD works with a bare return, too
{
    class Foo6b {
        has $.bar is rw;
        has $.baz is rw;

        submethod BUILD ($.bar = 10, $.baz?) {
            $!baz = 9;
            return;
        }
    }

    my $foo = Foo6b.new(bar => 7);
    ok($foo ~~ Foo6b, '... our Foo6b instance was created');
        
    is($foo.bar,        7, "getting a public rw attribute (1)"  );
    is($foo.baz,        9, "getting a public rw attribute (2)"  );
}

# L<S12/Attributes>
class Foo7e { has $.attr = 42 }
is Foo7e.new.attr, 42, "default attribute value (1)";

#?rakudo todo 'scoping issues'
{
    my $was_in_supplier = 0;
    sub forty_two_supplier() { $was_in_supplier++; 42 }
    class Foo10e { has $.attr = forty_two_supplier() }
    is eval('Foo10e.new.attr'), 42, "default attribute value (4)";
    is      $was_in_supplier, 1,  "forty_two_supplier() was actually executed";
    eval('Foo10e.new');
    is      $was_in_supplier, 2,  "forty_two_supplier() is executed per instantiation";
}

# check that doing something in submethod BUILD works
{
    class Foo7 {
        has $.bar is rw;
        has $.baz;

        submethod BUILD ($.bar = 5, $baz = 10 ) {
            $!baz = 2 * $baz;
        }
    }

    my $foo7 = Foo7.new();
    is( $foo7.bar, 5,
        'optional attribute should take default value without passed-in value' );
    is( $foo7.baz, 20,
        '... optional non-attribute should too' );
    $foo7    = Foo7.new( :bar(4), :baz(5) );
    is( $foo7.bar, 4,
        'optional attribute should take passed-in value over default' );
    is( $foo7.baz, 10,
        '... optional non-attribute should too' );
}


# check that args are passed to BUILD
{
    class Foo8 {
        has $.a;
        has $.b;
        
        submethod BUILD(:$foo, :$bar) {
            $!a = $foo;
            $!b = $bar;
        }
    }

    my $foo = Foo8.new(foo => 'c', bar => 'd');
    ok($foo.isa(Foo8), '... our Foo8 instance was created');
        
    is($foo.a, 'c', 'BUILD received $foo');
    is($foo.b, 'd', 'BUILD received $bar');
}

# check mixture of positional/named args to BUILD

{
    class Foo9 {
        has $.a;
        has $.b;
        
        submethod BUILD($foo, :$bar) {
            $.a = $foo;
            $.b = $bar;
        }
    }

    dies_ok({ Foo9.new('pos', bar => 'd') }, 'cannot pass positional to .new');
}

# check $self is passed to BUILD
{
    class Foo10 {
        has $.a;
        has $.b;
        has $.c;
    
        submethod BUILD($self: :$foo, :$bar) {
            $!a = $foo;
            $!b = $bar;
            $!c = 'y' if $self.isa(Foo10);
        }
    }

    {
        my $foo = Foo10.new(foo => 'c', bar => 'd');
        ok($foo.isa(Foo10), '... our Foo10 instance was created');
        
        is($foo.a, 'c', 'BUILD received $foo');
        is($foo.b, 'd', 'BUILD received $bar');
        is($foo.c, 'y', 'BUILD received $self');
    }
}

{
    class WHAT_ref {  };
    class WHAT_test {
        has WHAT_ref $.a;
        has WHAT_test $.b is rw;
    }
    my $o = WHAT_test.new(a => WHAT_ref.new(), b => WHAT_test.new());
    isa_ok $o.a.WHAT, WHAT_ref, '.WHAT on attributes';
    isa_ok $o.b.WHAT, WHAT_test, '.WHAT on attributes of same type as class';
    my $r = WHAT_test.new();
    lives_ok {$r.b = $r}, 'type check on recursive data structure';
    isa_ok $r.b.WHAT, WHAT_test, '.WHAT on recursive data structure';

}

{
    class ClosureWithself {
        has $.cl = { self.foo }
        method foo { 42 }
    }
    is ClosureWithself.new.cl().(), 42, 'use of self in closure on RHS of attr init works';
}


# Tests for clone.
{
    class CloneTest { has $.x is rw; has $.y is rw; }
    my $a = CloneTest.new(x => 1, y => 2);
    my $b = $a.clone();
    is $b.x, 1, 'attribute cloned';
    is $b.y, 2, 'attribute cloned';
    $b.x = 3;
    is $b.x, 3, 'changed attribute on clone...';
    is $a.x, 1, '...and original not affected';
    my $c = $a.clone(x => 42);
    is $c.x, 42, 'clone with parameters...';
    is $a.x, 1, '...leaves original intact...';
    is $c.y, 2, '...and copies what we did not change.';
}

# tests for *-1 indexing on classes, RT #61766
{
    class ArrayAttribTest {
        has @.a is rw;
        method init {
            @.a = <a b c>;
        }
        method m0 { @.a[0] };
        method m1 { @.a[*-2] };
        method m2 { @.a[*-1] };
    }
    my $o = ArrayAttribTest.new;
    $o.init;
    is $o.m0, 'a', '@.a[0] works';
    is $o.m1, 'b', '@.a[*-2] works';
    is $o.m2, 'c', '@.a[*-1] works';

    # RT #75266
    is ArrayAttribTest.new(a => <x y z>).a[2.0], 'z',
        'Can index array attributes with non-integers';
}

{
    class AttribWriteTest {
        has @.a;
        has %.h; 
        method set_array1 {
            @.a = <c b a>;
        }
        method set_array2 {
            @!a = <c b a>;
        }
        method set_hash1 {
            %.h = (a => 1, b => 2);
        }
        method set_hash2 {
            %!h = (a => 1, b => 2);
        }
    }

    my $x = AttribWriteTest.new; 
    # see Larry's reply to 
    # http://groups.google.com/group/perl.perl6.language/browse_thread/thread/2bc6dfd8492b87a4/9189d19e30198ebe?pli=1
    # on why these should fail.
    dies_ok { $x.set_array1 }, 'can not assign to @.array attribute';
    dies_ok { $x.set_hash1 },  'can not assign to %.hash attribute';
    lives_ok { $x.set_array2 }, 'can assign to @!array attribute';
    lives_ok { $x.set_hash2 },  'can assign to %!hash attribute';
}

# test that whitespaces after 'has (' are allowed.
# This used to be a Rakudo bug (RT #61914)
{
    class AttribWsTest {
        has ( $.this,
        $.that,
        );
    }
    my AttribWsTest $o .= new( this => 3, that => 4);
    is $o.this, 3, 'could use whitespace after "has ("';
    is $o.that, 4, '.. and a newline within the has() declarator';
}

# test typed attributes and === (was Rakudo RT#62902).
{
    class TA1 { }
    class TA2 {
        has TA1 $!a;
        method foo { $!a === TA1 }
    }
    #?rakudo todo 'Attribute type init'
    ok(TA2.new.foo, '=== works on typed attribute initialized with proto-object');
}

# used to be pugs regression
{
    class C_Test { has $.a; }
    sub f() { C_Test.new(:a(123)) }
    sub g() { my C_Test $x .= new(:a(123)); $x }

    is(C_Test.new(:a(123)).a, 123, 'C_Test.new().a worked');

    my $o = f();
    is($o.a, 123, 'my $o = f(); $o.a worked');

    is((try { f().a }), 123, 'f().a worked (so the pugsbug is fixed (part 1))');

    is((try { g().a }), 123, 'g().a worked (so the pugsbug is fixed (part 2))');
}

# was also a pugs regression:
# Modification of list attributes created with constructor fails

{
    class D_Test { 
        has @.test is rw; 
        method get () { shift @.test }
    }

    my $test1 = D_Test.new();
    $test1.test = [1];
    is($test1.test, [1], "Initialized outside constructor");
    is($test1.get ,  1 , "Get appears to have worked");
    is($test1.test,  [], "Get Worked!");

    my $test2 = D_Test.new( :test([1]) );
    is($test2.test, [1], "Initialized inside constructor");
    is($test2.get ,  1 , "Get appears to have worked");
    is($test2.test,  [], "Get Worked!");
}

# test typed attributes
# TODO: same checks on private attributes
{
    class TypedAttrib {
        has Int @.a is rw;
        has Int %.h is rw;
        has Int @!pa;
        has Int %!ph;
        method pac { @!pa.elems };
        method phc { %!ph.elems };
    }
    my $o = try { TypedAttrib.new };
    ok $o.defined, 'created object with typed attributes';
    is $o.a.elems, 0, 'typed public array attribute is empty';
    is $o.h.elems, 0, 'typed public hash attribute is empty';
    is $o.pac, 0, 'typed private array attribute is empty';
    is $o.phc, 0, 'typed private hash attribute is empty';

    #?rakudo todo 'typed arrays'
    ok $o.a.of === Int, 'array attribute is typed';
    lives_ok { $o.a = (2, 3) }, 'Can assign to typed drw-array-attrib';
    lives_ok { $o.a[2] = 4 },   'Can insert into typed rw-array-attrib';
    lives_ok { $o.a.push: 5 }, 'Can push onto typed rw-array-attrib';
    is $o.a.join('|'), '2|3|4|5', 
        '... all of the above actually worked (not only lived)';

    #?rakudo 3 todo 'typed arrays'
    dies_ok { $o.a = <foo bar> }, 'type enforced on array attrib (assignment)';
    dies_ok { $o.a[2] = $*IN   }, 'type enforced on array attrib (item assignment)';
    dies_ok { $o.a.push: [2, 3]}, 'type enforced on array attrib (push)';
    dies_ok { $o.a[42]<foo> = 3}, 'no autovivification (typed array)';

    #?rakudo todo 'over-eager auto-vivification bugs'
    is $o.a.join('|'), '2|3|4|5', 
        '... all of the above actually did nothing (not just died)';

    #?rakudo todo 'typed hash'
    ok $o.h.of === Int, 'hash attribute is typed';
    lives_ok {$o.h = { a => 1, b => 2 } }, 'assign to typed hash attrib';
    lives_ok {$o.h<c> = 3},                'insertion into typed hash attrib';
    lives_ok {$o.h.push: (d => 4) },       'pushing onto typed hash attrib';

    is_deeply $o.h<a b c d>, (1, 2, 3, 4),   '... all of them worked';

    #?rakudo 3 todo 'typed hash'
    dies_ok  {$o.h = { :a<b> }  },         'Type enforced (hash, assignment)';
    dies_ok  {$o.h<a> = 'b'  },            'Type enforced (hash, insertion)';
    dies_ok  {$o.h.push: (g => 'f') },     'Type enforced (hash, push)';
    dies_ok  {$o.h<blubb><bla> = 3 },      'No autovivification (typed hash)';
    #?rakudo todo 'typed hash'
    is_deeply $o.h<a b c d>, (1, 2, 3, 4),   'hash still unchanged';
}

# attribute initialization based upon other attributes
{
    class AttrInitTest {
        has $.a = 1;
        has $.b = 2;
        has $.c = $.a + $.b;
    }
    is AttrInitTest.new.c, 3,         'Can initialize one attribute based on another (1)';
    is AttrInitTest.new(a => 2).c, 4, 'Can initialize one attribute based on another (2)';
    is AttrInitTest.new(c => 9).c, 9, 'Can initialize one attribute based on another (3)';
}

# attributes with & sigil
{
    class CodeAttr1 { has &!m = sub { "ok" }; method f { &!m() } }
    is CodeAttr1.new.f, "ok", '&!m = sub { ... } works and an be called';

    class CodeAttr2 { has &.a = { "woot" }; method foo { &!a() } }
    is CodeAttr2.new.foo, "woot", '&.a = { ... } works and also declares &!a';
    is CodeAttr2.new.a().(), "woot", '&.a has accessor returning closure';

    class CodeAttr3 { has &!m = method { "OH HAI" }; method f { self.&!m() } }
    is CodeAttr3.new.f, 'OH HAI', '&!m = method { ... } and self.&!m() work';
}

{
    # from t/oo/class_inclusion_with_inherited_class.t
    # used to be a pugs regression

    role A {
        method t ( *@a ) {
            [+] @a;
        }
    }

    class B does A {}

    class C does A {
        has $.s is rw;
        has B $.b is rw;
        submethod BUILD {
            $.b = B.new;
            $.s = $.b.t(1, 2, 3);
        }
    }

    is C.new.s, 6, "Test class include another class which inherited from same role";
}

# RT #68370
{
    class RT68370 {
        has $!a;
        method rt68370 { $!a = 68370 }
    }

    dies_ok { RT68370.rt68370() },
        'dies: trying to modify instance attribute when invocant is type object';
}

# Binding an attribute (was RT #64850)
#?rakudo skip 'null pmc access on binding an attribute'
{
    class RT64850 {
        has $.x;
        method foo { $!x := 42 }
    }
    my $a = RT64850.new; 
    $a.foo;
    is $a.x, 42, 'binding to an attribute works';
}

#?rakudo skip 'RT 73368'
{
    class InitializationThunk {
        has $.foo = my $x = 5;
        method bar { $x };
    }

    is InitializationThunk.new.bar, 5, 'a lexical is not tied to a thunk';
}

# http://rt.perl.org/rt3/Ticket/Display.html?id=69202
{
    class TestMethodAll {
        has $.a;
        method x(Str $x) {};
        method all() { $!a }
    }
    is TestMethodAll.new(a => 5).all, 5, 'Can call a method all()';
}


# vim: ft=perl6
