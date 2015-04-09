#include "ruby.h"

static ID id_entries;
typedef struct _gen
{
    int curr;
    VALUE values;
} Generator;

//Is there a built in way to do this?
#define TEST(t) t?Qtrue:Qfalse

static VALUE t_init(int argc, VALUE *argv, VALUE self)
{
    Generator* gen;
    Data_Get_Struct(self, Generator, gen);
    if(argc > 0)
    {
        VALUE arr = rb_funcall(argv[0], id_entries, 0);
        gen->values = arr;
    }
    else
    {
        VALUE arr = rb_ary_new();
        gen->values = arr;
        rb_yield(self);
    }
    gen->curr = 0;
    return self;
}

static VALUE t_end_q(VALUE self)
{
    Generator* gen;
    Data_Get_Struct(self, Generator, gen);
    int size = RARRAY(gen->values)->len;
    int curr = gen->curr;
    return TEST(curr >= size);
}

static VALUE t_next_q(VALUE self)
{
    return TEST(!t_end_q(self));
}

static VALUE t_pos(VALUE self)
{
    Generator* gen;
    Data_Get_Struct(self, Generator, gen);
    int curr = gen->curr;
    return INT2NUM(curr);
}

static VALUE t_rewind(VALUE self)
{
    Generator* gen;
    Data_Get_Struct(self, Generator, gen);
    gen->curr = 0;
    return self;
}

static VALUE t_yield(VALUE self, VALUE element)
{
    Generator* gen;
    Data_Get_Struct(self, Generator, gen);
    rb_ary_push(gen->values, element);
    return gen->values;
}

static VALUE t_current(VALUE self)
{
    if(t_end_q(self))
    {
        rb_raise(rb_eEOFError, "no more elements available");
        return Qnil;
    }
    Generator* gen;
    Data_Get_Struct(self, Generator, gen);
    int curr = gen->curr;
    return rb_ary_entry(gen->values, curr);
}

static VALUE t_next(VALUE self)
{
    if(t_end_q(self))
    {
        rb_raise(rb_eEOFError, "no more elements available");
        return Qnil;
    }
    Generator* gen;
    Data_Get_Struct(self, Generator, gen);
    int curr = gen->curr++;
    VALUE temp = rb_ary_entry(gen->values, curr);
    return temp;
}

static VALUE t_each(VALUE self)
{
    Generator* gen;
    Data_Get_Struct(self, Generator, gen);
    gen->curr = 0;
    rb_iterate(rb_each, gen->values, rb_yield, 0);
    return self;
}

static void gen_free(void* p)
{
    free(p);
}

static void gen_mark(void* p)
{
    Generator* g = p;
    rb_gc_mark(g->values);
}

static VALUE gen_alloc(VALUE klass)
{
    Generator* gen = malloc(sizeof(Generator));
    VALUE obj;
    obj = Data_Wrap_Struct(klass, gen_mark, gen_free, gen);
    return obj;
}

VALUE cGen;
void Init_horndude_generator()
{
    id_entries = rb_intern("entries");
    cGen = rb_define_class("HorndudeGenerator", rb_cObject);
    rb_define_method(cGen, "initialize", t_init, -1);
    rb_define_method(cGen, "next?", t_next_q, 0);
    rb_define_method(cGen, "next", t_next, 0);
    rb_define_method(cGen, "end?", t_end_q, 0);
    rb_define_method(cGen, "pos", t_pos, 0);
    rb_define_method(cGen, "index", t_pos, 0);
    rb_define_method(cGen, "rewind", t_rewind, 0);
    rb_define_method(cGen, "yield", t_yield, 1);
    rb_define_method(cGen, "current", t_current, 0);
    rb_define_method(cGen, "each", t_each, 0);

    rb_define_alloc_func(cGen, gen_alloc);
}

