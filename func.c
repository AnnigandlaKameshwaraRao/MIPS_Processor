int main() {
    int array[5] = {0, 1, 2, 3, 4};  // Array in memory
    int sum = 0;
    for (int i = 0; i < 5; i++) {
        sum += array[i];  // Load array[i]
    }
    array[0] = sum;       // Store sum back to array[0]
    return sum;
}