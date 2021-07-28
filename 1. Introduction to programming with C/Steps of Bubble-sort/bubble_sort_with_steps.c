#include <stdio.h>

#define MAX_SIZE 1000

// signatures of other functions
void bubble_sort(int *array, int size);
void print_array(int *array, int size, int index1, int index2);


// main function:
// reads input and calls bubble sort function
int main() {
    int array[MAX_SIZE]; // define array
    int input;      // variable to read a number
    int size = 0;   // size of entered sequence

    // a loop to read user input
    printf("Enter a sequence of numbers to start sorting:\n");
    printf("(enter 0 to end it)\n");
    for (int i = 0; i < MAX_SIZE; i++)
    {
        scanf("%d", &input);

        if (input == 0)
        {
            break;
        }
        else
        {
            array[i] = input;
            size++;
        }
    }

    // call bubble sort function
    bubble_sort(array, size);

    return 0;
}

// Bubble sort function
void bubble_sort(int *array, int size)
{
    int temp;   // auxiliary variable

    // main loop of bubble sort algorithm
    for(int i = 0; i < size; i++)
    {
        for(int j = i+1; j < size; j++)
        {
            if(array[j] < array[i])
            {
                temp = array[i];
                array[i] = array[j];
                array[j] = temp;
            }

            // call print function after the recent step of swapping
            print_array(array, size, i, j);
        }
    }
}

// a function for printing each step of the sorting
// index1 and index2 are used to show the latest elements that are swapped
void print_array(int *array, int size, int index1, int index2)
{
    for (int i = 0; i < size; i++)
    {
        if (i == index1 || i == index2)
        {
            // print a number with an arrow
            printf("-> %d ", array[i]);
        }
        else
        {
            // print a number without an arrow
            printf("   %d ", array[i]);
        }

        // print starts
        for (int j = 0; j < array[i]; j++)
        {
            printf("*");
        }

        printf("\n");
    }

    printf("------------------\n");
}


