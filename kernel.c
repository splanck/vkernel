void kernel_main(void) {
    char *video = (char*)0xB8000;
    const char *msg = "Hello, world!";
    for (int i = 0; msg[i]; ++i) {
        video[i * 2] = msg[i];
        video[i * 2 + 1] = 0x07;
    }
}
