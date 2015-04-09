//
// Ruby extension implementing a priority queue
// 
// This is a fibonacy heap priority queue implementation.
//
// (c) 2005 Brian Schröder
//
// Please submit bugreports to priority_queue@brian-schroeder.de
//
// This extension is under the same license as ruby.
// 
// Do not hold me reliable for anything that happens to you, your programs or
// anything else because of this extension. It worked for me, but there is no
// guarantee it will work for you.
//
// Except for using a value except of a void* the priority queue c-code is ruby
// agnostic.
//
#include <stdlib.h>
#include <stdio.h>
#include "ruby.h"
#include <math.h>

typedef _Bool bool;

#define false 0;
#define true 1;

typedef struct struct_priority_node {
  unsigned int degree;
  VALUE priority;
  VALUE object;
  struct struct_priority_node* parent;
  struct struct_priority_node* child;
  struct struct_priority_node* left;
  struct struct_priority_node* right;
  bool mark;
} priority_node;

typedef struct {
  priority_node* rootlist;
  priority_node* min;
  unsigned int length;
  int (*compare_function)(VALUE p1, VALUE p2); // Should return < 0 for a < b, 0 for a == b, > 0 for a > b
} priority_queue;

////////////////////////////////////////////////////////////////////////////////
// Node Manipulation Functions
////////////////////////////////////////////////////////////////////////////////

// Create a priority node structure
priority_node* create_priority_node(VALUE object, VALUE priority) {
  priority_node* result = ALLOC(priority_node);
  result->degree   = 0;
  result->priority = priority;
  result->object = object;
  result->parent = NULL;
  result->child = NULL;
  result->left = result;
  result->right = result;
  result->mark = false;  
  return result;
}

// Use this to free a node struct
void priority_node_free(priority_node* n) {
  free(n);
}

static
  void priority_node_free_recursively(priority_node* n) {
    if (!n)
      return;

    priority_node* n1 = n;
    do {
      priority_node *n2 = n1->right;
      priority_node_free_recursively(n1->child);
      priority_node_free(n1);
      n1 = n2;
    } while(n1 != n);
  }

// link two binomial heaps
static 
  priority_node* link_nodes(priority_queue* q, priority_node* b1, priority_node* b2) {
    if (q->compare_function(b2->priority, b1->priority) < 0)
      return link_nodes(q, b2, b1);
    b2->parent = b1;
    priority_node* child = b1->child;
    b1->child = b2;
    if (child) {
      b2->left  = child->left;
      b2->left->right = b2;
      b2->right = child;
      b2->right->left = b2;
    } else {
      b2->left = b2;
      b2->right = b2;
    }
    b1->degree++;
    b2->mark = false;
    return b1;
  }

////////////////////////////////////////////////////////////////////////////////
// Queue Manipulation Functions
////////////////////////////////////////////////////////////////////////////////

// Create an empty priority queue
priority_queue* create_priority_queue(int (*compare_function)(VALUE, VALUE)) {
  priority_queue *result = ALLOC(priority_queue);
  result->min = NULL;
  result->rootlist = NULL;
  result->length = 0;
  result->compare_function = compare_function;
  return result;
}

// Free a priority queue and all the nodes it contains
void priority_queue_free(priority_queue* q) {
  priority_node_free_recursively(q->rootlist);
  free(q);
}

// Meld two queues into one new queue. We take the first queue and the rootnode of the second queue.
static
priority_queue* meld_queue(priority_queue* q1, priority_node* q2, unsigned int length_q2) {
  if (!q1->rootlist) {
    q1->rootlist = q2;
    q1->min = q2;
    q1->length = length_q2;
  } else {
    priority_node* r1 = q1->rootlist->left;
    priority_node* r2 = q2->left;  

    q1->rootlist->left = r2;
    r2->right = q1->rootlist;

    q2->left = r1;
    r1->right = q2;

    q1->length = q1->length + length_q2;

    if (q1->compare_function(q2->priority, q1->min->priority) < 0)
      q1->min = q2;
  }

  return q1;
}

// Add an object and a priority to a priority queue. Returns a pointer to a
// priority_node structure, which can be used in delete_node and priority_queue_decrease_priority
// operations.
priority_node* priority_queue_add_node(priority_queue* q, VALUE object, VALUE priority) {
  priority_node* result = create_priority_node(object, priority);
  meld_queue(q, result, 1);
  return result;
}

static 
priority_node* delete_first(priority_queue* q) {
  if (q->rootlist) {
    priority_node* result = q->rootlist;
    if (result == result->right)
      q->rootlist = NULL;
    else {
      q->rootlist = result->right;
      result->left->right = result->right;
      result->right->left = result->left;
      result->right = result;
      result->left = result;
    }
    return result;
  } else {
    return NULL;
  }
}

static
void assert_pointers_correct(priority_node* n) {
  if (!n) return;

  priority_node *n1 = n->right;
  while(n != n1) {
    if (n1->child && (n1 != n1->child->parent)) 
      printf("Eltern-Kind Zeiger inkorrekt: %p\n", n);

    if (n1 != n1->right->left)
      printf("Rechts-links inkorrekt: %p\n", n);

    if (n1 != n1->left->right)
      printf("links-Rechts inkorrekt: %p\n", n);

    assert_pointers_correct(n1->child);
    n1 = n1->right;
  }
}

// Consolidate a queue in amortized O(log n)
static 
void consolidate_queue(priority_queue* q) {
  unsigned int length = q->length;
  
  unsigned int array_size = 2 * log(length) / log(2) + 1;
  priority_node* tree_by_degree[array_size]; // TODO: We need only 2log n entries
  unsigned int i;
  for (i=0; i<array_size; i++)
    tree_by_degree[i] = NULL;

  priority_node* n = NULL;
  while (((n = delete_first(q)))) {
    priority_node* n1 = NULL;
    while (((n1 = tree_by_degree[n->degree]))) {
      tree_by_degree[n->degree] = NULL;
      n = link_nodes(q, n, n1);
    }
    tree_by_degree[n->degree] = n;
  }

  // Find minimum value in O(log n) // Only if we shorten the array
  q->rootlist = NULL;
  q->min = NULL;
  for (i=0; i<array_size; i++) {    
    if (tree_by_degree[i] != NULL) {
      meld_queue(q, tree_by_degree[i], 0);
    }
  }

  q->length = length;
}

// Delete and extract priority_node with minimal priority O(log n)
priority_node* priority_queue_pop_min(priority_queue* q) {
  if (!q->rootlist) return NULL;
  priority_node* min = q->min;

  if (q->length == 1){ // length == 1
    q->rootlist = NULL;
    q->min = NULL;
    q->length = 0;
  } else {
    unsigned int length = q->length;
    // Abtrennen.
    if (q->min == q->rootlist) {
      if (q->min == q->min->right) {
	q->rootlist = NULL;
	q->min = NULL;
      } else {
	q->rootlist = q->min->right;
      }
    }
    min->left->right = min->right;
    min->right->left = min->left;
    min->left = min;
    min->right = min;
    if (min->child) {
      // Kinder und Eltern trennen, Markierung aufheben, und kleinstes Kind bestimmen.
      priority_node* n = min->child;
      priority_node* min2 = n;
      do {
	n->parent = NULL;
	n->mark = false;
	n = n->right;
	if (q->compare_function(n->priority, min2->priority) < 0)
	  min2 = n;
      } while (n!=min->child);

      // Kinder einfügen
      meld_queue(q, min2, 0);
    }

    // Größe anpassen
    q->length = length-1;

    // Wieder aufhübschen
    consolidate_queue(q);
  }

  return min;
}

static
  priority_queue* cut_node(priority_queue* q, priority_node* n) {
    if (!n->parent)
      return q;  
    n->parent->degree--;
    if (n->parent->child == n) {
      if (n->right == n)
	n->parent->child = NULL;
      else
	n->parent->child = n->right;  
    }
    n->parent = NULL;
    n->right->left = n->left;
    n->left->right = n->right;

    n->right = q->rootlist;
    n->left  = q->rootlist->left;
    q->rootlist->left->right = n;
    q->rootlist->left = n;
    q->rootlist = n;

    n->mark = false;

    return q;
  }

// Decrease the priority of a priority_node and restructure the queue
  priority_queue* priority_queue_decrease_priority(priority_queue* q, priority_node* n, VALUE priority) {
    if (q->compare_function(n->priority, priority) <= 0) // Todo: Versickern erlauben
      return q;
    n->priority = priority;
    if (q->compare_function(n->priority, q->min->priority) < 0)
      q->min = n;
    if (!(n->parent) || (q->compare_function(n->parent->priority, n->priority) <= 0))
      return q;
    do {
      priority_node* p = n->parent;
      cut_node(q, n);
      n = p;
    } while (n->mark && n->parent);
    if (n->parent)
      n->mark = true;
    return q;
  }

// Get the priority_node with the minimum priority from a queue
priority_node* priority_queue_min(priority_queue *q) {
  return q->min;
}

////////////////////////////////////////////////////////////////////////////////
// Define the ruby classes
////////////////////////////////////////////////////////////////////////////////

static int id_compare_operator;
static int id_format;

priority_queue* get_pq_from_value(VALUE self) {
  priority_queue *q; 
  Data_Get_Struct(self, priority_queue, q);
  return q;
}

static
int value_compare_function(VALUE a, VALUE b) {
  return FIX2INT(rb_funcall((VALUE) a, id_compare_operator, 1, (VALUE) b));
}

static
void pq_free(void *p) {
  priority_queue_free(p);  
}

static
void pq_mark_recursive(priority_node* n) {
  if (!n) return;
  rb_gc_mark((VALUE) n->object);
  rb_gc_mark((VALUE) n->priority);
  priority_node* n1 = n->child;
  if (!n1) return;
  do {
    pq_mark_recursive(n1);
    n1 = n1->right;
  } while (n1 != n->child);
}

static
void pq_mark(void *q) {  
  priority_node* n1 = ((priority_queue*) q)->rootlist;
  if (!n1)
    return;
  priority_node* n2 = n1;
  do {
    pq_mark_recursive(n1);
    n1 = n1->right;
  } while (n1 != n2);
}

static 
VALUE pq_alloc(VALUE klass) {
  priority_queue *q;
  VALUE object;

  q = create_priority_queue(&value_compare_function);

  object = Data_Wrap_Struct(klass, pq_mark, pq_free, q);

  return object;
}

static
VALUE pq_init(VALUE self) {
  rb_iv_set(self, "@__node_by_object__", rb_hash_new());

  return self;
}

static
VALUE pq_push(VALUE self, VALUE object, VALUE priority) {
  VALUE hash = rb_iv_get(self, "@__node_by_object__");

  priority_queue* q = get_pq_from_value(self);

  priority_node* n = priority_queue_add_node(q, object, priority);

  rb_hash_aset(hash, object, ULONG2NUM((unsigned long) n)); // TODO: This is hackish, maybe its better to also wrap the nodes.

  return self;
}

static
VALUE pq_min(VALUE self) {
  priority_queue* q = get_pq_from_value(self);

  priority_node* n = priority_queue_min(q);
  if (n)
    return (VALUE) n->object;
  else
    return Qnil;
}

static
VALUE pq_pop_min(VALUE self) {
  VALUE hash = rb_iv_get(self, "@__node_by_object__");
  priority_queue* q = get_pq_from_value(self);

  priority_node* n = priority_queue_pop_min(q);

  if (n) {
    rb_hash_delete(hash, (VALUE) n->object); // TODO: Maybe we have a problem here with garbage collection of n->object?
    return (VALUE) n->object;  
  } else {
    return Qnil;
  }
}

static
VALUE pq_decrease_priority(VALUE self, VALUE object, VALUE priority) {
  VALUE hash = rb_iv_get(self, "@__node_by_object__");
  priority_queue* q = get_pq_from_value(self);

  priority_queue_decrease_priority(q, (priority_node*) NUM2ULONG(rb_hash_aref(hash, object)), priority);

  return self;
}

static
VALUE pq_length(VALUE self) {
  priority_queue* q = get_pq_from_value(self);

  return INT2NUM(q->length);
}


// Dot a single node of a priority queue. Called by pq_to_dot to do the inner work.
// (I'm not proud of this function ;-( )
static
void pq_node2dot(VALUE result_string, priority_node* n, unsigned int level) {
  if (n == NULL) return;  
  unsigned int i;
  for (i=0; i<level; i++) rb_str_cat2(result_string, "  ");  
  if (n->mark)
    rb_str_concat(result_string,
	rb_funcall(Qnil, id_format, 4, rb_str_new2("NODE%i [label=\"%s (%s)\"];\n"), 
	  ULONG2NUM((unsigned long) n), n->object, n->priority));
  else
    rb_str_concat(result_string,
	rb_funcall(Qnil, id_format, 4, rb_str_new2("NODE%i [label=\"%s (%s)\",shape=box];\n"), 
	  ULONG2NUM((unsigned long) n), n->object, n->priority));
  if (n->child != NULL) {
    priority_node* n1 = n->child;
    do {
      pq_node2dot(result_string, n1, level + 1);
      for (i=0; i<level; i++) rb_str_cat2(result_string, "  ");  
      rb_str_concat(result_string,
	  rb_funcall(Qnil, id_format, 4, rb_str_new2("NODE%i -> NODE%i;\n"), 
	    ULONG2NUM((unsigned long) n), ULONG2NUM((unsigned long) n1)));
      n1 = n1->right;
    } while(n1 != n->child);
  }
}

// Print a priority queue as a dot-graph
// (I'm not proud of this function ;-( )
static
VALUE pq_to_dot(VALUE self) {
  priority_queue* q = get_pq_from_value(self);

  VALUE result_string = rb_str_new2("digraph fibonaccy_heap {\n");
  if (q->rootlist) {
    priority_node* n1 = q->rootlist;
    do {    
      pq_node2dot(result_string, n1, 1);
      n1 = n1->right;
    } while(n1 != q->rootlist);
  }
  rb_str_cat2(result_string, "}\n");
  return result_string;
}

VALUE cPriorityQueue;
void Init_priority_queue() {
  id_compare_operator = rb_intern("<=>");
  id_format = rb_intern("format");

  cPriorityQueue = rb_define_class("PriorityQueue", rb_cObject);

  rb_define_alloc_func(cPriorityQueue, pq_alloc);
  rb_define_method(cPriorityQueue, "initialize", pq_init, 0);
  rb_define_method(cPriorityQueue, "push", pq_push, 2);
  rb_define_method(cPriorityQueue, "min", pq_min, 0);
  rb_define_method(cPriorityQueue, "pop_min", pq_pop_min, 0);
  rb_define_method(cPriorityQueue, "decrease_priority", pq_decrease_priority, 2);
  rb_define_method(cPriorityQueue, "length", pq_length, 0);
  rb_define_method(cPriorityQueue, "to_dot", pq_to_dot, 0);
}
