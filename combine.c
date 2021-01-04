	string input= "";
	uint32_t key[4] = {0,0,0,0};

	cout<<"Enter 8 characters: ";
	getline(cin,input);

	cout<<"Enter a 4 digits key: ";
    for(int i = 0 ; i < 4 ; i++)
    {
        cin>>key[i];
    }
    TEA(input, key);

	return 0;
