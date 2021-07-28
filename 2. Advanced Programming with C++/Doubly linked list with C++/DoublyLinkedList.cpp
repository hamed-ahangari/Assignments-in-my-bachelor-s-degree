#include <iostream> // cin, cout
#include <string>   // getline

using namespace std;

// Doubly linked list class
class DoublyLinkedList
{
private:
    char data;  // data would be a single character
    DoublyLinkedList* prev; // pointer to the previous node
    DoublyLinkedList* next; // pointer to the next node

public:
    /* Constructor */
    DoublyLinkedList(char ch, DoublyLinkedList* previous_node, DoublyLinkedList* next_node)
    {
        data = ch;
        next = next_node;
        prev = previous_node;
    }

    /* Getter and setter methods*/

    char get_data()
    {
        return data;
    }

    void set_data(char ch)
    {
        data = ch;
    }

    DoublyLinkedList* get_prev()
    {
        return prev;
    }

    void set_prev(DoublyLinkedList* previous_node)
    {
        prev = previous_node;
    }

    DoublyLinkedList* get_next()
    {
        return next;
    }

    void set_next(DoublyLinkedList* next_node)
    {
        next = next_node;
    }

};


// Step A:
// 1) Create a doubly linked list
// 2) make nodes and fill them with user input
DoublyLinkedList* step_A()
{
    cout << "\n" << "---------------> STEP A <---------------" << "\n";

    DoublyLinkedList* head = NULL;

    string input;
    cout << "Enter an string to fill the linked list with it (alphabets and 0-9):" << "\n";
    getline(cin, input);


    DoublyLinkedList* currentNode = head;

    for (int i = 0; i < input.length(); ++i)
    {
        if (head == NULL)
        {
            head = new DoublyLinkedList(input[0], NULL, NULL);
            currentNode = head;
        }
        else
        {
            DoublyLinkedList* newNode = new DoublyLinkedList(input[i], currentNode, NULL);
            currentNode->set_next(newNode);

            currentNode = newNode;
        }
    }

    cout << "\n" << "The doubly linked list created..." << "\n\n";

    return head;
}

// Step B:
// 1) insert digit "1" after each character "a" in the list
// 2) insert digit "2" before each character "b" in the list
// 3) remove all nodes with character "c" as data
void step_B(DoublyLinkedList* head)
{
    cout << "\n" << "---------------> STEP B <---------------" << "\n";

    DoublyLinkedList* currentNode = head;

    while (currentNode != NULL)
    {
        if (currentNode->get_data() == 'a')
        {
            cout << "Found character 'a' in the list..." << "\n";

            DoublyLinkedList* newNode = new DoublyLinkedList('1', currentNode, currentNode->get_next());

            if (currentNode->get_next() != NULL)
            {
                currentNode->get_next()->set_prev(newNode);
            }
            currentNode->set_next(newNode);
        }
        else if (currentNode->get_data() == 'b')
        {
            cout << "Found character 'b' in the list..." << "\n";

            DoublyLinkedList* newNode = new DoublyLinkedList('2', currentNode->get_prev(), currentNode);

            if (currentNode->get_prev() != NULL)
            {
                currentNode->get_prev()->set_next(newNode);
            }
            currentNode->set_prev(newNode);
        }
        else if (currentNode->get_data() == 'c')
        {
            cout << "Found character 'c' in the list..." << "\n";

            // first: keep the address of the next node
            DoublyLinkedList* next = currentNode->get_next();

            // second: cut the connections to remove this node ('c' node)
            if (currentNode->get_prev() != NULL)
            {
                currentNode->get_prev()->set_next(currentNode->get_next());
            }

            if (currentNode->get_next() != NULL)
            {
                currentNode->get_next()->set_prev(currentNode->get_prev());
            }

            delete currentNode;

            currentNode = next;
            continue; // continue the loop with next node of this deleted node
        }


        currentNode = currentNode->get_next();  // go to the next node (for case 'a' and case 'b'. for 'c' it will go to next by that 'continue' command)
    }
}


void printList(DoublyLinkedList* head)
{
    DoublyLinkedList* currentNode = head;

    while (currentNode != NULL)
    {
        cout << "'" << currentNode->get_data() << "'";

        // move pointer to the next node
        currentNode = currentNode->get_next();
        if (currentNode != NULL)
        {
            cout << " -> ";   // if we have a next node, then we print "->"
        }
    }

    cout << "\n\n";
}

// main function
int main()
{
    // step A
    DoublyLinkedList* headOfList;
    headOfList = step_A();

    cout << "Print BEFORE running step B:" << "\n";
    printList(headOfList);

    // step B
    step_B(headOfList);
    cout << "Print AFTER running step B:" << "\n";
    printList(headOfList);
}
