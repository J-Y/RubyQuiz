#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void cls(void)
{
  printf("\033[2J");
}

void home(void)
{
  printf("\033[1;1H");
}

int get_even_positive(char* desc)
{
  int n = 0;
  char s[21];
  while( n <= 0 || n/2*2 != n)
  {
    printf("Please enter %s (must be even and positive): ", desc);
    scanf("%20s", s);
    n = atoi(s);
  }
  return n;
}

double get_probability(char* desc)
{
  double p = -1.0;
  char s[21];
  while (p < 0.0 || p > 100.0)
  {
    printf("Please enter probability for %s (in percent, float): ",
           desc);
    scanf("%20s", s);
    p = atof(s);
  }
  return p / 100.0;
}

int **initialize_state(int cols, int rows, double prob)
{
  int i;
  int j;
  int **a;

  a = (int **) calloc(rows, sizeof(int *));
  for (i = 0; i < rows; i++)
  {
    a[i] = (int *) calloc(cols, sizeof(int));
  }
  for (i = 0; i < rows; i++)
  {
    for (j = 0; j < cols; j++)
    {
      a[i][j] = (rand() < RAND_MAX * prob) ? 1 : 0;
    }
  }
  a[rows/2][cols/2] = 2;
  return a;
}

void display_state(int **state, int tick, int cols, int rows)
{
  int i;
  int j;
  char filename[15];
  FILE *file;

  home();
  printf("Simulation tick %d\n", tick);
  sprintf(filename, "tick_%05d.pgm", tick);
  file = fopen(filename, "w");
  fprintf(file, "P2\n");
  fprintf(file, "# %s\n", filename);
  fprintf(file, "%d %d\n", cols, rows);
  fprintf(file, "2/n");
  for (i = 0; i < rows; i++)
  {
    for (j = 0; j < cols; j++)
    {
      putc("012"[state[i][j]], file);
      putc('\n', file);
    }
  }
  fclose(file);
}

int frozen_out(int **state, int cols, int rows)
{
  int i;
  int j;

  for (i = 0; i < rows; i++)
  {
    for (j = 0; j < cols; j++)
    {
      if (state[i][j] == 1)
      {
        return 0;
      }
    }
  }
  return 1;
}

int main(void)
{
  int okay = 0;
  int tick = 0;
  int offset;
  int cols;
  int rows;
  int i, i1;
  int j, j1;
  int h00, h01, h10, h11;
  double prob;
  char s[21];
  int **state;

  while (!okay)
  {
    cls();
    cols = get_even_positive("number of columns");
    rows = get_even_positive("number of rows");
    prob = get_probability("vapor");
    printf("You want:\n");
    printf("\t%d\tcolums\n", cols);
    printf("\t%d\trows\n", rows);
    printf("\t%f\tas the initial probabilty for vapor in percent\n",
           prob * 100.0);
    printf("IS THAT CORRECT? If so please answer with: yes\n");
    scanf("%20s", s);
    okay = !strcmp(s, "yes");
    if (!okay)
    {
      puts("Please re-enter data.");
    }
  }
  state = initialize_state(cols, rows, prob);
  cls();
  while(1)
  {
    display_state(state, tick, cols, rows);
    if (frozen_out(state, cols, rows))
    {
      return 0;
    }
    offset = (tick++ + 1) % 2;
    for (i = offset; i < rows; i += 2)
    {
      i1 = (i + 1) % rows;
      for (j = offset; j < cols; j += 2)
      {
        j1 = (j + 1) % cols;
        if (state[i][j]   == 2 ||
            state[i][j1]  == 2 ||
            state[i1][j]  == 2 ||
            state[i1][j1] == 2)
        {
          if (state[i][j]   == 1) state[i][j]   = 2;
          if (state[i][j1]  == 1) state[i][j1]  = 2;
          if (state[i1][j]  == 1) state[i1][j]  = 2;
          if (state[i1][j1] == 1) state[i1][j1] = 2;
        }
        else
        {
          h00 = state[i][j];
          h01 = state[i][j1];
          h10 = state[i1][j];
          h11 = state[i1][j1];
          if (rand() < RAND_MAX/2)
          {
            state[i][j]   = h01;
            state[i][j1]  = h11;
            state[i1][j]  = h00;
            state[i1][j1] = h10;
          }
          else
          {
            state[i][j]   = h10;
            state[i][j1]  = h00;
            state[i1][j]  = h11;
            state[i1][j1] = h01;
          }
        }
      }
    }
  }
  return 0;
}
