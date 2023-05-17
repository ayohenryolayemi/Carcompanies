---
title: create a Car Company Smart Contract on the Celo Blockchain
description: This tutorial will teach you how to create a car company on celo blockchain
authors:
  - name: ayohenryolayemi
---

# Table of content
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Smart Contract](#smart-contract)
  - [How The Contract Works](#how-the-contract-works)
  - [Contract Overview](#contract-overview)
  - [Adding a Car](#adding-a-car)
  - [Retrieving Car Information](retrieving-car-information)
  - [Interacting with Cars](#interacting-with-cars)
  - [Buying a Car](#buying-a-car)
  - [Additional Helper Functions](#additional-helper-functions)
- [Frontend](#frontend)
  - [Importing Dependencies](#importing-dependencies)
  - [Initializing Variables and Constants](#initializing-variables-and-constants)
  - [Connect to Wallet Function](#connect-to-wallet-function)
  - [Get User Balance and Car Data](#get-user-balance-and-car-data)
  - [Add Car](#add-car)
  - [Like, Dislike, and Add Review](#like-dislike-and-add-review)
  - [Addcar.js](#addcarjs)
  - [Wrapping up](#wrapping-up)
- [Cars.js](#carsjs)
  - [Import React and useState](#import-react-and-usestate)
  - [Create the Cars Component](#create-the-cars-component)
  - [Export the Cars component](#export-the-cars-component)
  - [Initialize State](#initialize-state)
  - [Render Car Cards](#render-car-cards)
  - [Display Car Information](#display-car-information)
  - [Like/Dislike Buttons](#likedislike-buttons)
  - [Display Likes and Dislikes](#display-likes-and-dislikes)
  - [Add Review Form](#add-review-form)
  - [Display Car Reviews](#display-car-reviews)
  - [Export the Cars Component](#export-the-cars-component)
  - [Import the Cars Component in App.js](#import-the-cars-component-in-appjs)
  - [Add the Cars Component to the Rendered JSX](#add-the-cars-component-to-the-rendered-jsx)
  - [Implement the AddCar Component](#implement-the-addcar-component)
  - [Implement the Cars Component](#implement-the-cars-component)
  - [Update App.js to Use the Cars Component](#update-appjs-to-use-the-cars-component)
  - [Add Styling to the Components](add-styling-to-the-components)
  - [Test the Application](#test-the-application)
- [NavigationBar.js](#navigationbarjs)
  - [Importing Dependencies](#importing-dependencies)
  - [Creating the NavigationBar Component](#creating-the-navigationbar-component)
  - [Navigation Bar JSX](#navigation-bar-jsx)
  - [Exporting the NavigationBar Component](#exporting-the-navigationbar-component)
  - [Invoking the NavigationBar Component](#invoking-the-navigationbar-component)
- [Deployment](#deployment)
- [Conclusion](#conclusion)
- [Next Steps](#next-steps)
    

## Introduction

In this tutorial, we will walk you through a smart contract called `Carcompanies` that allows users to interact with a decentralized car marketplace. The smart contract enables users to add cars for sale, buy cars, leave reviews, and interact with the marketplace.

## Prerequisites

To follow along with this tutorial, you should have a basic understanding of Ethereum, Solidity programming language, and the concepts of smart contracts.

## Smart Contract

Let's begin writing our smart contract in Remix IDE

This is the complete code.

```solidity
// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;


interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);


  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Carcompanies
 * @dev A smart contract for managing car companies and their cars.
 **/
contract Carcompanies {

    uint internal carLength = 0;
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;


    // declaring the struct for the review
     struct Review {
        uint256 postId;
        address reviewerAddress;
        string reviewerMessage;
    }


    struct Car {
        address payable owner;
        string brand;
        string model;
        string image;
        uint likes;
        uint dislikes;
        uint price;
        uint carsAvailable;
        uint numberOfreview;
    }

    mapping (uint256=> Car) internal cars;
    mapping (uint => Review[]) internal reviewsMap;// mapping reviews

    /**
     * @dev Event emitted when a new car is added to the contract.
     * @param owner The address of the car owner.
     * @param brand The brand of the car.
     * @param model The model of the car.
     * @param image The image of the car.
     * @param price The price of the car.
     * @param carsAvailable The number of cars available.
     **/
    event CarAdded(
    address indexed owner,
    string brand,
    string model,
    string image,
    uint price,
    uint carsAvailable
    );

     /**
     * @dev Event emitted when a car is liked.
     * @param index The index of the car.
     * @param likes The updated number of likes for the car.
     **/
    event CarLiked(uint indexed index, uint likes);

    /**
     * @dev Event emitted when a car is disliked.
     * @param index The index of the car.
     * @param dislikes The updated number of dislikes for the car.
    **/  
    event CarDisliked(uint indexed index, uint dislikes);

    /**
     * @dev Event emitted when a review is added to a car.
     * @param index The index of the car.
     * @param reviewerAddress The address of the reviewer.
     * @param reviewerMessage The message of the review.
    **/
    event CarReviewed(uint indexed index, address reviewerAddress, string reviewerMessage);

    /**
     * @dev Event emitted when a car is bought.
     * @param index The index of the car.
     * @param buyer The address of the buyer.
    **/
    event CarBought(uint indexed index, address buyer);


    /**
     * @dev Adds a new car to the contract.
     * @param _brand The brand of the car.
     * @param _model The model of the car.
     * @param _image The image of the car.
     * @param _price The price of the car.
     * @param _carsAvailable The number of cars available.
    **/
    function addCar(
        string memory _brand,
        string memory _model,
        string memory _image,
        uint _price,
        uint _carsAvailable
    )public{
        require(bytes(_brand).length > 0, "Brand should not be empty");
        require(bytes(_model).length > 0, "Model should not be empty");
        require(bytes(_image).length > 0, "Image should not be empty");
        require(_price > 0, "Price should be greater than zero");
        require(_carsAvailable > 0, "Cars available should be greater than zero");
        uint _numberOfreview = 0;


        cars[carLength] = Car(
            payable(msg.sender),
            _brand,
            _model,
            _image,
            0,
            0,
            _price,
            _carsAvailable,
            _numberOfreview
        );
        carLength++;
        emit CarAdded(msg.sender, _brand, _model, _image, _price, _carsAvailable);
    }

     /**
     * @dev Retrieves the details of a car.
     * @param _index The index of the car.
     * @return owner The address of the car owner.
     * @return brand The brand of the car.
     * @return model The model of the car.
     * @return image The image of the car.
     * @return likes The number of likes for the car.
     * @return dislikes The number of dislikes for the car.
     * @return price The price of the car.
     * @return carsAvailable The number of cars available.
     * @return numberOfreview The number of reviews for the car.
     * @return reviews The array of reviews for the car.
     **/   
    function getCar(uint _index)public view returns(
        address payable owner,
        string memory brand,
        string memory model,
        string memory image,
        uint likes,
        uint dislikes,
        uint price,
        uint carsAvailable,
        uint numberOfreview,
        Review[] memory
    ){
        require(_index < carLength, "Invalid car index");

        Car memory c = cars[_index];
        Review[] memory reviews = reviewsMap[_index];
        return (
            c.owner,
            c.brand,
            c.model,
            c.image,
            c.likes,
            c.dislikes,
            c.price,
            c.carsAvailable,
            c.numberOfreview,
            reviews
        );
    }

    /**
     * @dev Increases the like count for a car.
     * @param _index The index of the car.
     **/
    function likeCar(uint _index)public{
        require(_index < carLength, "Invalid car index");
        require(cars[_index].owner != msg.sender, "Cannot like your own car");
        require(cars[_index].owner != msg.sender);
        cars[_index].likes++;
        emit CarLiked(_index, cars[_index].likes);
    }

    /**
     * @dev Increases the dislike count for a car.
     * @param _index The index of the car.
    **/
    function dislikeCar(uint _index)public{
        require(_index < carLength, "Invalid car index");
        require(cars[_index].owner != msg.sender, "Cannot dislike your own car");
         require(cars[_index].owner != msg.sender);
        cars[_index].dislikes++;
        emit CarDisliked(_index, cars[_index].dislikes);
    }

    /**
     * @dev Adds a review to a car.
     * @param _index The index of the car.
     * @param _reviews The review message.
    **/
   function addReview(uint _index, string memory _reviews) public{
       require(_index < carLength, "Invalid car index");
        require(cars[_index].owner != msg.sender, "Cannot review your own car");
        require(cars[_index].owner != msg.sender);
        reviewsMap[_index].push(Review(_index, address(msg.sender), _reviews));
        cars[_index].numberOfreview++;
        emit CarReviewed(_index, msg.sender, _reviews);
    }

    /**
     * @dev Buys a car.
     * @param _index The index of the car.
    **/
    function buyCar(uint _index) public payable  {
        require(_index < carLength, "Invalid car index");
        require(cars[_index].carsAvailable > 0, "sold out");
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            cars[_index].owner,
            cars[_index].price
          ),
          "Can not perform transactions."
        );
        cars[_index].carsAvailable--;

        emit CarBought(_index, msg.sender);
    }

     /**
     * @dev Retrieves the length of the cars array.
     * @return The length of the cars array.
     **/
    function getCarLength() public view returns (uint){
        return (carLength);
    }

    /**
     * @dev Retrieves the length of the reviews array for a specific car.
     * @param _index The index of the car.
     * @return The length of the reviews array.
    **/
    function getReviewsLength(uint _index) public view returns (uint) {
        require(_index < carLength, "Invalid car index");
        return reviewsMap[_index].length;
    }
}

```

## How The Contract Works

Let's explain how the contract works!

### Contract Overview

Let's start by understanding the purpose and structure of the smart contract.

The `Carcompanies` contract is designed to facilitate a decentralized car marketplace. It allows users to perform the following actions:

- Add a car for sale.
- Retrieve information about a car.
-   Like or dislike a car.
-   Add reviews for a car.
-   Buy a car.

The contract uses a custom ERC20 token, represented by the `IERC20Token` interface, for conducting transactions within the marketplace.

**Contract Structure and variables**

Now, let's dive into the structure of the smart contract and its variables.

```solidity
pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
  // Interface functions
}

contract Carcompanies {
    // Contract variables
    uint internal carLength = 0;
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    // Structs
    struct Review {
        // Review struct fields
    }

    struct Car {
        // Car struct fields
    }

    // Mappings
    mapping (uint256 => Car) internal cars;
    mapping (uint => Review[]) internal reviewsMap;

    // Contract functions
}

```

The contract starts with a `carLength` variable to keep track of the number of cars in the marketplace. The `cUsdTokenAddress` variable represents the address of a custom ERC20 token used for transactions.

Next, the contract defines two structs: `Review` and `Car`. The Review struct represents a user review for a car, containing fields such as the post ID, reviewer's address, and reviewer's message. The `Car` struct represents a car for sale, with fields for the owner, brand, model, image, likes, dislikes, price, available quantity, and the number of reviews for the car.

The contract also includes two mappings: `cars` and `reviewsMap`. The `cars` mapping maps a car index to its corresponding Car struct, allowing efficient retrieval of car information. The `reviewsMap` mapping maps a car index to an array of `Review` structs, enabling multiple reviews for each car.

### Adding a Car

Let's continue by implementing the functionality to add a car for sale.

```solidity
 /**
     * @dev Adds a new car to the contract.
     * @param _brand The brand of the car.
     * @param _model The model of the car.
     * @param _image The image of the car.
     * @param _price The price of the car.
     * @param _carsAvailable The number of cars available.
    **/
    function addCar(
        string memory _brand,
        string memory _model,
        string memory _image,
        uint _price,
        uint _carsAvailable
    )public{
        require(bytes(_brand).length > 0, "Brand should not be empty");
        require(bytes(_model).length > 0, "Model should not be empty");
        require(bytes(_image).length > 0, "Image should not be empty");
        require(_price > 0, "Price should be greater than zero");
        require(_carsAvailable > 0, "Cars available should be greater than zero");
        uint _numberOfreview = 0;


        cars[carLength] = Car(
            payable(msg.sender),
            _brand,
            _model,
            _image,
            0,
            0,
            _price,
            _carsAvailable,
            _numberOfreview
        );
        carLength++;
        emit CarAdded(msg.sender, _brand, _model, _image, _price, _carsAvailable);
    }

```

The `addCar` function allows a user to add a car to the marketplace. It takes parameters such as the brand, model, image URL, price, and available quantity of the car. Inside the function, a new `Car` struct is created with the provided details, and the car is added to the cars mapping. The `carLength` variable is incremented to keep track of the total number of cars.

### Retrieving Car Information

Let's implement the functionality to retrieve information about a car.

```solidity
 /**
     * @dev Retrieves the details of a car.
     * @param _index The index of the car.
     * @return owner The address of the car owner.
     * @return brand The brand of the car.
     * @return model The model of the car.
     * @return image The image of the car.
     * @return likes The number of likes for the car.
     * @return dislikes The number of dislikes for the car.
     * @return price The price of the car.
     * @return carsAvailable The number of cars available.
     * @return numberOfreview The number of reviews for the car.
     * @return reviews The array of reviews for the car.
     **/   
    function getCar(uint _index)public view returns(
        address payable owner,
        string memory brand,
        string memory model,
        string memory image,
        uint likes,
        uint dislikes,
        uint price,
        uint carsAvailable,
        uint numberOfreview,
        Review[] memory
    ){
        require(_index < carLength, "Invalid car index");

        Car memory c = cars[_index];
        Review[] memory reviews = reviewsMap[_index];
        return (
            c.owner,
            c.brand,
            c.model,
            c.image,
            c.likes,
            c.dislikes,
            c.price,
            c.carsAvailable,
            c.numberOfreview,
            reviews
        );
    }

```

The `getCar` function takes the index of a car as a parameter and returns various details about the car, including the owner's address, brand, model, image URL, likes, dislikes, price, available quantity, the number of reviews, and an array of reviews. It retrieves the `Car` struct associated with the provided index from the `cars` mapping and returns the corresponding information.

### Interacting with Cars

Let's implement functions to interact with cars, such as liking, disliking, and adding reviews.

```solidity
/**
     * @dev Increases the like count for a car.
     * @param _index The index of the car.
     **/
    function likeCar(uint _index)public{
        require(_index < carLength, "Invalid car index");
        require(cars[_index].owner != msg.sender, "Cannot like your own car");
        require(cars[_index].owner != msg.sender);
        cars[_index].likes++;
        emit CarLiked(_index, cars[_index].likes);
    }

    /**
     * @dev Increases the dislike count for a car.
     * @param _index The index of the car.
    **/
    function dislikeCar(uint _index)public{
        require(_index < carLength, "Invalid car index");
        require(cars[_index].owner != msg.sender, "Cannot dislike your own car");
         require(cars[_index].owner != msg.sender);
        cars[_index].dislikes++;
        emit CarDisliked(_index, cars[_index].dislikes);
    }

    /**
     * @dev Adds a review to a car.
     * @param _index The index of the car.
     * @param _reviews The review message.
    **/
   function addReview(uint _index, string memory _reviews) public{
       require(_index < carLength, "Invalid car index");
        require(cars[_index].owner != msg.sender, "Cannot review your own car");
        require(cars[_index].owner != msg.sender);
        reviewsMap[_index].push(Review(_index, address(msg.sender), _reviews));
        cars[_index].numberOfreview++;
        emit CarReviewed(_index, msg.sender, _reviews);
    }

```

The `likeCar` function allows a user to like a specific car. It increments the likes counter for the corresponding car in the `cars` mapping.

The `dislikeCar` function enables a user to `dislike` a car. It increments the dislikes counter for the specified car in the `cars` mapping.

The `addReview` function allows a user to add a review for a car. It takes the index of the car and the review message as parameters. A new `Review` struct is created with the provided details and added to the `reviewsMap` mapping, associated with the corresponding car index. The `numberOfreview` counter for the car is incremented to keep track of the total number of reviews.

### Buying a Car

Let's implement the functionality to buy a car from the marketplace.

```solidity
/**
     * @dev Buys a car.
     * @param _index The index of the car.
    **/
    function buyCar(uint _index) public payable  {
        require(_index < carLength, "Invalid car index");
        require(cars[_index].carsAvailable > 0, "sold out");
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            cars[_index].owner,
            cars[_index].price
          ),
          "Can not perform transactions."
        );
        cars[_index].carsAvailable--;

        emit CarBought(_index, msg.sender);
    }

```

The `buyCar` function allows a user to purchase a car from the marketplace. It takes the index of the car as a parameter. The function checks if the car is available for purchase by verifying the `carsAvailable` field in the corresponding `Car` struct. If the car is available, it transfers the specified `price` of the car from the buyer's address to the car's owner using the custom ERC20 token. The `carsAvailable` counter is decremented to reflect the reduced availability of the car.

### Additional Helper Functions

Let's implement two additional helper functions to retrieve the length of the car array and the number of reviews for a specific car.

```solidity
 /**
     * @dev Retrieves the length of the cars array.
     * @return The length of the cars array.
     **/
    function getCarLength() public view returns (uint){
        return (carLength);
    }

    /**
     * @dev Retrieves the length of the reviews array for a specific car.
     * @param _index The index of the car.
     * @return The length of the reviews array.
    **/
    function getReviewsLength(uint _index) public view returns (uint) {
        require(_index < carLength, "Invalid car index");
        return reviewsMap[_index].length;
    }

```

The `getCarLength` function returns the total number of cars in the marketplace by retrieving the value of the `carLength` variable.

The `getReviewsLength` function takes the index of a car as a parameter and returns the total number of reviews for that car by retrieving the length of the corresponding array in the `reviewsMap` mapping.

## Frontend

### Importing Dependencies

The code begins by importing necessary dependencies and components for the application. It imports the `NavigationBar`, `AddCar`, `useState`, `useEffect`, and other required libraries.

```solidity
import './App.css';
import { NavigationBar } from './components/NavigationBar';
import { AddCar } from './components/AddCar';
import { useState, useEffect, useCallback } from "react";
import Web3 from "web3";
import { newKitFromWeb3 } from "@celo/contractkit";
import BigNumber from "bignumber.js";
import Carcompanies from "./contracts/Carcompanies.abi.json";
import IERC from "./contracts/IERC.abi.json";
import { Cars } from './components/Cars';

```
Here, the code imports CSS styles from App.css, various components such as `NavigationBar`, `AddCar`, and `Cars` from their respective files, and several libraries including React hooks like `useState`, `useEffect`, and `useCallback`. It also imports Web3, ContractKit, and other JSON files containing the ABIs (Application Binary Interface) for the smart contracts.

### Initializing Variables and Constants

Next, the code initializes variables and constants required for the application. It sets the contract address, cUSD contract address, and ERC20 decimal value. These values are used to interact with the smart contract and handle token transactions.

### Connect to Wallet Function

The next step is to define a function that connects the application to the user's wallet:

```solidity
const connectToWallet = async () => {
  if (window.celo) {
    try {
      await window.celo.enable();
      const web3 = new Web3(window.celo);
      let kit = newKitFromWeb3(web3);

      const accounts = await kit.web3.eth.getAccounts();
      const userAddress = accounts[0];

      kit.defaultAccount = userAddress;

      setAddress(userAddress);
      setKit(kit);
    } catch (error) {
      console.log(error);
    }
  } else {
    alert("Error Occurred");
  }
};

```
This function uses the `window.celo` object to enable the user's wallet. It creates a `web3` instance using the Celo provider and initializes a ContractKit instance `using newKitFromWeb3`.

### Get User Balance and Car Data

```solidity
const getBalance = useCallback(async () => {
  try {
    const balance = await kit.getTotalBalance(address);
    const USDBalance = balance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2);

    const contract = new kit.web3.eth.Contract(Carcompanies, contractAddress);
    setContract(contract);
    setcUSDBalance(USDBalance);
  } catch (error) {
    console.log(error);
  }
}, [address, kit]);

const getCar = useCallback(async () => {
  const carLength = await contract.methods.getCarLength().call();
  const cars = [];
  for (let index = 0; index < carLength; index++) {
    let _cars = new Promise(async (resolve, reject) => {
      let car = await contract.methods.getCar(index).call();

      resolve({
        index: index,
        owner: car[0],
        brand: car[1],
        model: car[2],
        image: car[3],
        likes: car[4],
        dislikes: car[5],
        price: car[6],
        carsAvailable: car[7],
        numberOfReview: car[8],
        reviews: car[9]
      });
    });
    cars.push(_cars);
  }

  const _cars = await Promise.all(cars);
  setCars(_cars);
}, [contract]);

```
The `getBalance` function retrieves the user's cUSD token balance. It uses the ContractKit instance and the user's address to get the total balance. The balance is converted to a readable format with the specified decimal places and stored in the `cUSDBalance` state variable.

### Get Cars

The `getCar` function retrieves information about the cars from the smart contract. It uses the `getCarLength` and `getCar` functions of the contract to get the total number of cars and retrieve the details of each car. The car details are mapped to an array of car objects and stored in the `car` state variable.

### Add Car

```solidity
const addCar = async (_brand, _model, _image, price, _carsAvailable) => {
  const _price = new BigNumber(price).shiftedBy(ERC20_DECIMALS).toString();

  try {
    await contract.methods
      .addCar(_brand, _model, _image, _price, _carsAvailable)
      .send({ from: address });
    getCar();
  } catch (error) {
    alert(error);
  }
};

```
The `addCar` function allows users to add a new car to the marketplace. It takes the brand, model, image URL, price, and available quantity as parameters. The function converts the price to the required format and calls the `addCar` function of the smart contract, passing the provided details. After adding the car, it calls the `getCar` function to update the car list.

### Like, Dislike, and Add Review

```solidity
const likeCar = async (index) => {
  try {
    await contract.methods.likeCar(index).send({ from address });
} catch (error) {
console.log(error);
} finally {
getCar();
}
};

const dislikeCar = async (index) => {
try {
await contract.methods.dislikeCar(index).send({ from: address });
} catch (error) {
console.log(error);
} finally {
getCar();
}
};

const addReview = async (_index, _review) => {
try {
await contract.methods
.addReview(_index, _review)
.send({ from: address });
getCar();
} catch (error) {
alert(error);
}
};

const buyCar = async (_index) => {
const cUSDContract = new kit.web3.eth.Contract(IERC, cUSDContractAddress);
try {
await cUSDContract.methods
.approve(contractAddress, cars[_index].price)
.send({ from: address });
await contract.methods.BuyCar(_index).send({ from: address });
getCar();
getBalance();
alert("Congratulations on your successful purchase!");
} catch (error) {
alert(error);
}
};

```

The `likeCar` function calls the `likeCar` method of the smart contract, passing the car index and the user's address. It then calls the `getCar` function to update the car data.

The `dislikeCar` function is similar to `likeCar` but calls the `dislikeCar` method instead.

The `addReview` function allows users to add a review to a specific car. It takes the car index and the review as parameters and sends the transaction to the smart contract. After the transaction is successful, it updates the car data by calling `getCar`.

The `buyCar` function enables users to purchase a car from the marketplace. It first creates an instance of the cUSD contract using the ContractKit provider. It then approves the smart contract to spend the required amount of cUSD tokens by calling `approve` on the cUSD contract. After approval, it calls the `BuyCar` method of the smart contract, passing the car index and the user's address. Finally, it updates the car data and the user's balance by calling `getCar` and `getBalance`, respectively, and displays a success message.

### Lifecycle Hooks and Render
The code utilizes several lifecycle hooks to perform actions at specific times during the component's lifecycle.

```javascript
useEffect(() => {
  connectToWallet();
}, []);

useEffect(() => {
  if (kit && address) {
    getBalance();
  }
}, [kit, address, getBalance]);

useEffect(() => {
  if (contract) {
    getCar();
  }
}, [contract, getCar]);
  }
}, [contract, getCar]);

The `useEffect` hook is used to run side effects after the component has rendered. In this code, there are three `useEffect` hooks.

-   The first `useEffect` hook is used to connect to the user's wallet. It is triggered only once when the component mounts, and it calls the `connectToWallet` function.

-   The second `useEffect` hook is used to fetch the user's balance. It is triggered whenever the `kit` and `address` variables change. It calls the `getBalance` function to update the cUSD balance.

-   The third `useEffect` hook is used to fetch the cars from the smart contract. It is triggered whenever the `contract` variable changes. It calls the `getCar` function to update the car list.

Finally, the render function returns the JSX markup of the application:

```solidity
return (
  <div className="App">
    <NavigationBar cUSDBalance={cUSDBalance} />
    <Cars
      userWallet={address}
      cars={cars}
      addReview={addReview}
likeCar={likeCar}
dislikeCar={dislikeCar}
buyCar={buyCar}
/>
<AddCar addCar={addCar} />

  </div>
);

```

Finally, in the return statement, the component renders the different components of the application. It renders the `NavigationBar` component, passing the `cUSDBalance` as a prop. It also renders the `Cars` component, passing various props such as `userWallet`, `Cars` (the array of cars), and the functions `addReview`, `buyCar`, `likeCar`, and `dislikeCar`. Lastly, it renders the AddCar component, passing the addCar function as a prop.

That's the overall explanation of the code. It's a decentralized application (DApp) that allows users to add cars to a marketplace, view car details, like/dislike cars, add reviews, and buy cars using cUSD tokens on the Celo blockchain.

The smart contract defines the functionality for adding cars, managing reviews, and executing car purchases. The frontend application interacts with the smart contract using the ContractKit library and allows users to connect their Celo wallets, view their cUSD balance, add cars, interact with car listings, and make purchases.

### Addcar.js

### Import the required dependencies

```Solidity
import React from 'react';
import { useState } from "react";

```
We import the `React` module from the `react` package and the `useState` hook from the `react` package as well.

**Define the `AddCar` funtional component**

```Solidity
export const AddCar = (props) => {

```
We define the `AddCar` component using the ES6 arrow function syntax. It takes a single parameter `props`, which allows us to access properties passed to the component.

**Initialize state variables using the `useState` hook**

```Solidity
const [brand, setBrand] = useState('');
const [model, setModel] = useState('');
const [image, setImage] = useState('');
const [price, setPrice] = useState('');
const [carsAvailable, setCarsAvailable] = useState('');

```
We use the `useState` hook to initialize multiple state variables. Each state variable is paired with a corresponding setter function that allows us to update the state. Here, we initialize `brand`, `model`, `image`, `price`, and `carsAvailable` with empty strings as their initial values.

**Define the JSX markup for the form**

```Solidity
return (
  <div>
    <form>
      <div class="form-row">
        <input
          type="text"
          class="form-control"
          value={brand}
          onChange={(e) => setBrand(e.target.value)}
          placeholder="Car Brand"
        />
        <input
          type="text"
          class="form-control mt-2"
          value={model}
          onChange={(e) => setModel(e.target.value)}
          placeholder="Car Model"
        />
        <input
          type="text"
          class="form-control mt-2"
          value={image}
          onChange={(e) => setImage(e.target.value)}
          placeholder="Image URL"
        />
        <input
          type="text"
          class="form-control mt-2"
          value={price}
          onChange={(e) => setPrice(e.target.value)}
          placeholder="Price"
        />
        <input
          type="text"
          class="form-control mt-2"
          value={carsAvailable}
          onChange={(e) => setCarsAvailable(e.target.value)}
          placeholder="Number of Cars Available"
        />
        <button
          type="button"
          onClick={() => props.addCar(brand, model, image, price, carsAvailable)}
          class="btn btn-dark mt-2"
        >
          Add Car
        </button>
      </div>
    </form>
  </div>
);

```
In the `return` statement, we define the JSX markup for the form. It consists of several input fields for the car brand, model, image URL, price, and number of cars available. Each input field is associated with a corresponding state variable and uses the `onChange` event to update the state when the user enters data. The "Add Car" button triggers the `props.addCar` function when clicked, passing the entered values as arguments.

### Export the `AddCar` component

```Solidity
export default AddCar;

```
We export the `AddCar` component as the default export, allowing it to be imported in other files.

That's it! The `AddCar` component provides a form for adding car details and uses the `useState` hook to manage the form inputs' state. When the "Add Car" button is clicked, it triggers the `props.addCar` function passed to the component

**Pass the `addCar` function as a prop**

```Solidity
<button
  type="button"
  onClick={() => props.addCar(brand, model, image, price, carsAvailable)}
  class="btn btn-dark mt-2"
>
  Add Car
</button>

```
In the button element, we set the `onClick` event to trigger the props.addCar function when the button is clicked. We pass the values of `brand`, `model`, `image`, `price`, and `carsAvailable` as arguments to the `addCar` function.

By passing the `addCar` function as a prop to the `AddCar` component, we allow the parent component to define the logic for adding a car and handle the data accordingly.

### Return the JSX markup

```Solidity
return (
  <div>
    <form>
      {/* Input fields */}
      {/* Button */}
    </form>
  </div>
);

```

We return the JSX markup for the  `AddCar` component, which includes the form elements for entering car details.

### Export the `AddCar` component

```Solidity
export default AddCar;

```

We export the `AddCar` component as the default export, allowing it to be imported and used in other components.

That's it! The `AddCar` component provides a form with input fields for adding car details. When the "Add Car" button is clicked, it triggers the `addCar` function passed as a prop and passes the entered values as arguments. This allows the parent component to handle the logic for adding the car and perform any necessary data manipulation or updates.

You can use this `AddCar` component within your application to provide a user-friendly interface for adding car data.

**Utilizing the `AddCar` component in the main application**

```Solidity
import React from 'react';
import { useState } from "react";
import { AddCar } from './components/AddCar';

function App() {
  // State variables and other code...

  const addCar = (brand, model, image, price, carsAvailable) => {
    // Logic to add a car
    // Perform necessary operations, such as making API calls or updating the contract

    // Example implementation:
    // ...
  };

  return (
    <div className="App">
      {/* Other components */}
      <AddCar addCar={addCar} />
    </div>
  );
}

export default App;

```

In the `App` component, we import the `AddCar` component and include it within the JSX markup. We pass the `addCar` function as a prop to the `AddCar` component.

The `addCar` function is defined within the `App` component and serves as the handler for adding a car. This is where you can implement the necessary logic to add a car, such as making API calls, updating the contract, or performing any other operations required by your application.

By passing the `addCar` function as a prop to the `AddCar` component, we enable communication between the `AddCar` component and the parent `App` component. The `AddCar` component can trigger the `addCar` function when the user submits the form, passing the entered car details as arguments.

### Completing the `addCar` function logic

Within the `App` component, you need to implement the logic for the `addCar` function to handle the addition of a new car. This logic will depend on your specific requirements and the technologies you're using. Here's an example implementation:

```Solidity
const addCar = (brand, model, image, price, carsAvailable) => {
  // Perform the necessary operations to add a car
  // Example implementation:
  const newCar = {
    brand: brand,
    model: model,
    image: image,
    price: price,
    carsAvailable: carsAvailable
  };

  // Update the car list or send the new car data to the server
  // Example implementation:
  const updatedCarList = [...cars, newCar];
  setCars(updatedCarList);
};

```

In this example implementation, we create a new car object using the entered values. Then, we update the car list by adding the new car to the existing list. The updated car list is stored in the `cars` state variable using the `setCars` function (assuming you have defined the cars state and the `setCars` function).

You can modify this implementation to suit your specific needs. For example, if you're interacting with a smart contract, you might need to make a contract call to add the car or update the blockchain data accordingly.

By completing the logic for the `addCar` function, you enable the ability to add a new car using the `AddCar` component and handle the data as required by your application.

That's it! You have now integrated the `AddCar` component into your application, allowing users to add new cars and perform the necessary actions associated with adding car data.

### Styling the `AddCar` component

To enhance the user experience, it's essential to style the `AddCar` component to make it visually appealing and align with the overall design of your application. You can use CSS or a CSS framework of your choice to style the component.

Here's an example of how you can style the `AddCar` component using Bootstrap CSS classes:

```Solidity
import React from 'react';
import { useState } from 'react';

export const AddCar = (props) => {
  const [brand, setBrand] = useState('');
  const [model, setModel] = useState('');
  const [image, setImage] = useState('');
  const [price, setPrice] = useState('');
  const [carsAvailable, setCarsAvailable] = useState('');

  const handleSubmit = (event) => {
    event.preventDefault();
    props.addCar(brand, model, image, price, carsAvailable);
    // Reset form values
    setBrand('');
    setModel('');
    setImage('');
    setPrice('');
    setCarsAvailable('');
  };

  return (
    <div className="add-car">
      <h2>Add a Car</h2>
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="brand">Car Brand:</label>
          <input
            type="text"
            className="form-control"
            id="brand"
            value={brand}
            onChange={(e) => setBrand(e.target.value)}
            placeholder="Enter the car brand"
            required
          />
        </div>
        <div className="form-group">
          <label htmlFor="model">Car Model:</label>
          <input
            type="text"
            className="form-control"
            id="model"
            value={model}
            onChange={(e) => setModel(e.target.value)}
            placeholder="Enter the car model"
            required
          />
        </div>
        <div className="form-group">
          <label htmlFor="image">Image URL:</label>
          <input
            type="text"
            className="form-control"
            id="image"
            value={image}
            onChange={(e) => setImage(e.target.value)}
            placeholder="Enter the image URL"
            required
          />
        </div>
        <div className="form-group">
          <label htmlFor="price">Price:</label>
          <input
            type="text"
            className="form-control"
            id="price"
            value={price}
            onChange={(e) => setPrice(e.target.value)}
            placeholder="Enter the car price"
            required
          />
        </div>
        <div className="form-group">
          <label htmlFor="carsAvailable">Cars Available:</label>
          <input
            type="text"
            className="form-control"
            id="carsAvailable"
            value={carsAvailable}
            onChange={(e) => setCarsAvailable(e.target.value)}
            placeholder="Enter the number of cars available"
            required
          />
        </div>
        <button type="submit" className="btn btn-primary">Add Car</button>
      </form>
    </div>
  );
};

```

In this example, we use Bootstrap CSS classes to structure the form and input fields. Each input field is wrapped in a `form-group` class for proper spacing and alignment. The `form-control` class is applied to the input fields to style them as Bootstrap form controls.

The `handleSubmit` function is called when the form is submitted. It prevents the default form submission behavior, calls the `addCar` function passed via props, and resets the form values using the `setBrand`, `setModel`, `setImage`,

### Styling the AddCar component (continued)

```Solidity
// ...previous code

export const AddCar = (props) => {
  // ...previous code

  const handleSubmit = (event) => {
    event.preventDefault();
    props.addCar(brand, model, image, price, carsAvailable);
    // Reset form values
    setBrand('');
    setModel('');
    setImage('');
    setPrice('');
    setCarsAvailable('');
  };

  return (
    <div className="add-car">
      <h2>Add a Car</h2>
      <form onSubmit={handleSubmit}>
        {/* ...previous code */}
        <button type="submit" className="btn btn-primary">Add Car</button>
      </form>
    </div>
  );
};

// ...export statement

```

In the updated code, the `handleSubmit` function now includes additional logic to reset the form values after the car is added successfully. This ensures that the input fields are cleared for the next car entry.

By wrapping the entire form inside a `<div>` with the class name `add-car`, we create a container that can be styled separately if desired. This allows you to apply custom styles to the `AddCar` component as a whole.

The `<h2>` element with the text "Add a Car" provides a heading for the form, making it clear what the purpose of the form is.

The form itself has an `onSubmit` event listener that calls the `handleSubmit` function when the form is submitted. This prevents the default form submission behavior and triggers the logic to add the car using the `props.addCar` function.

The "Add Car" button has the `btn` and `btn-primary` classes from Bootstrap, which give it a styled appearance.

**Incorporating the `AddCar` component into the main application**

To complete the integration of the `AddCar` component into the main application, we need to import and render it within the `App` component.

In your `App.js` file, update the import statement to include the `AddCar` component:

```Solidity
// ...previous imports

import { AddCar } from './components/AddCar';

// ...previous code

function App() {
  // ...previous code

  return (
    <div className="App">
      {/* ...previous code */}
      <AddCar addCar={addCar} />
    </div>
  );
}

export default App;

```

Here, we import the `AddCar` component and add it to the JSX code within the `App` component, specifically inside the <div> with the class name `"App"`. This ensures that the `AddCar` component is rendered and displayed as part of the main application.

Now, when you run your application, you should see the "Add a Car" form rendered on the screen. Users can input the details of a new car and click the "Add Car" button to add it to the car inventory. The form values will be cleared after submission, allowing the user to add multiple cars consecutively.

That's it! You've successfully implemented the `AddCar` component and integrated it into your car company application. Users can now add cars to the inventory through the user interface.

### Testing the `AddCar` component

It's important to test the functionality of the `AddCar` component to ensure that cars can be successfully added to the inventory. You can perform manual testing by running your application and using the form to add cars. However, in a production environment, it's recommended to write automated tests to validate the behavior of your components.

Here's an example of how you can write a basic test for the `AddCar` component using the React Testing Library:

```Solidity
import React from 'react';
import { render, fireEvent } from '@testing-library/react';
import { AddCar } from './AddCar';

test('adds a car to the inventory', () => {
  const addCarMock = jest.fn();
  const { getByPlaceholderText, getByText } = render(<AddCar addCar={addCarMock} />);

  // Fill in the form fields
  const brandInput = getByPlaceholderText('Car Brand');
  const modelInput = getByPlaceholderText('Car Model');
  const imageInput = getByPlaceholderText('Image URL');
  const priceInput = getByPlaceholderText('Price');
  const carsAvailableInput = getByPlaceholderText('Number of Cars Available');

  fireEvent.change(brandInput, { target: { value: 'Tesla' } });
  fireEvent.change(modelInput, { target: { value: 'Model S' } });
  fireEvent.change(imageInput, { target: { value: 'https://example.com/tesla-model-s.jpg' } });
  fireEvent.change(priceInput, { target: { value: '50000' } });
  fireEvent.change(carsAvailableInput, { target: { value: '10' } });

  // Submit the form
  const addButton = getByText('Add Car');
  fireEvent.click(addButton);

  // Check if the addCar function was called with the correct arguments
  expect(addCarMock).toHaveBeenCalledWith('Tesla', 'Model S', 'https://example.com/tesla-model-s.jpg', '50000', '10');
});

```

In this test, we create a mock function `addCarMock` using `jest.fn()`, which will simulate the `addCar` function passed as a prop to the `AddCar` component. We render the `AddCar` component and retrieve the necessary elements from the rendered component using the `getByPlaceholderText` and `getByText` functions provided by React Testing Library.

We simulate user interaction by changing the values of the form fields using `fireEvent.change`. After filling in the form, we simulate a form submission by clicking the "Add Car" button using `fireEvent.click`.

Finally, we use the expect function to check if the `addCarMock` function was called with the expected arguments. This ensures that the `addCar` function is triggered correctly when the form is submitted.

You can write more tests to cover different scenarios, such as submitting an empty form or testing the form reset behavior. Testing helps ensure the correctness and reliability of your code, especially as your application grows in complexity.

### Wrapping up

Congratulations! You have successfully implemented the `AddCar` component in your car company application. Users can now add cars to the inventory through the user interface, and the data will be sent to the smart contract.

Throughout this tutorial, you learned how to:

-   Create a form component in React to capture car details.
-   Handle form submission and trigger an action to add a car.
-   Utilize state hooks to manage form input values.
-   Style the form using Bootstrap classes for a visually appealing layout.
-   Integrate the `AddCar` component into the main application.
-   Write a basic test to verify the functionality of the `AddCar`

## Cars.js

### Import React and useState

The code starts by importing the necessary dependencies: React and useState from the "react" package. React is the library we use to create components, and useState is a React Hook that allows us to manage state within functional components.

```Solidity
import React from 'react';
import { useState } from 'react';

```

### Create the Cars Component

The `Cars` component is a functional component that displays a list of cars along with their details and provides functionality to add reviews, like/dislike cars, and display car information.

```Solidity
export const Cars = (props) => {
  // State for the review input field
  const [review, setReview] = useState('');

  return (
    <div className="card-container">
      {/* Iterate over each car and display its details */}
      {props.Cars.map((car) => (
        <div className="col-3">
          <div className="card" key={car.index}>
            {/* Display car image */}
            <img className="card-img-top" src={car.image} alt="Card image cap" />
            <div className="card-body">
              {/* Display car brand and model */}
              <h5 className="card-title">Brand: {car.brand}</h5>
              <h6 className="card-subtitle">Model: {car.model}</h6>

              {/* Display car availability */}
              <h5 className="card-title">{car.carsAvailable} Cars Available</h5>

              {/* Display car price */}
              <h2>Car Price: {car.price / 1000000000000000000} cUSD</h2>

              {/* Like button */}
              {props.userWallet !== car.owner && (
                <button onClick={() => props.likeCar(car.index)} className="btn btn-success btn-b">
                  Like
                </button>
              )}

              {/* Dislike button */}
              {props.userWallet !== car.owner && (
                <button onClick={() => props.dislikeCar(car.index)} className="btn btn-dark btn-b">
                  Dislike
                </button>
              )}

              {/* Display likes and dislikes */}
              {props.userWallet !== car.owner && (
                <small className="int">
                  {car.likes} Likes {car.dislikes} Dislikes
                </small>
              )}

              {/* Add review form */}
              {props.userWallet !== car.owner && (
                <form>
                  <div className="form-r">
                    {/* Review input field */}
                    <input
                      type="text"
                      className="form-control mt-4"
                      value={review}
                      onChange={(e) => setReview(e.target.value)}
                      placeholder="Enter review"
                    />

                    {/* Add review button */}
                    <button
                      type="button"
                      onClick={() => props.addReview(car.index, review)}
                      className="btn btn-dark mt-2"
                    >
                      Add review
                    </button>
                  </div>
                </form>
              )}

              {/* Display car reviews */}
              <h5 className="card-title mt-5">Reviews</h5>
              {car.reviews.map((c) => (
                <p className="card-text mt-2" key={c.postId}>
                  Message: {c.reviewerMessage}
                </p>
              ))}
            </div>
          </div>
        </div>
      ))}
    </div>
  );
};

```

### Export the Cars component

The `Cars` component is exported so that it can be imported and used in other parts of the application.

```Solidity
export default Cars;

```

### Initialize State

Inside the `Cars` component, we initialize the state using the `useState` hook. We create a state variable called ``review` and a corresponding setter function `setReview`. The `review` state will be used to store the input value of the review field.

```Solidity
const [review, setReview] = useState('');

```

### Render Car Cards

The `Cars` component maps over the `props.Cars` array, which contains the car data passed from the parent component. For each car, it renders a card element with the car's details.

```Solidity
<div className="card-container">
  {props.Cars.map((car) => (
    <div className="col-3">
      <div className="card" key={car.index}>
        <img className="card-img-top" src={car.image} alt="Card image cap" />
        <div className="card-body">
          <h5 className="card-title">Brand: {car.brand}</h5>
          <h6 className="card-subtitle">Model: {car.model}</h6>
          {/* ... */}
        </div>
      </div>
    </div>
  ))}
</div>

```

### Display Car Information

Inside each card, we display the car's brand, model, availability, and price.

```Solidity
<h5 className="card-title">Brand: {car.brand}</h5>
<h6 className="card-subtitle">Model: {car.model}</h6>
<h5 className="card-title">{car.carsAvailable} Cars Available</h5>
<h2>Car Price: {car.price / 1000000000000000000} cUSD</h2>

```

### Like/Dislike Buttons

If the user wallet address is not the same as the car's owner, we render the like and dislike buttons. These buttons trigger the `props.likeCar` and `props.dislikeCar` functions when clicked.

```Solidity
{props.userWallet !== car.owner && (
  <button onClick={() => props.likeCar(car.index)} className="btn btn-success btn-b">
    Like
  </button>
)}
{props.userWallet !== car.owner && (
  <button onClick={() => props.dislikeCar(car.index)} className="btn btn-dark btn-b">
    Dislike
  </button>
)}

```

### Display Likes and Dislikes

If the user wallet address is not the same as the car's owner, we display the number of likes and dislikes for the car.

```Solidity
{props.userWallet !== car.owner && (
  <small className="int">
    {car.likes} Likes {car.dislikes} Dislikes
  </small>
)}

```

### Add Review Form

If the user wallet address is not the same as the car's owner, we render the add review form. This form includes an input field to enter the review and a button to submit it. The value of the input field is controlled by the `review` state.

```Solidity
{props.userWallet !== car.owner && (
  <form>
    <div className="form-r">
      <input
        type="text"
        className="form-control mt-4"
        value={review}
        onChange={(e) => setReview(e.target.value)}
        placeholder="Enter review"
      />
      <button
        type="button"
        onClick={() => props.addReview(car.index, review)}
        className="btn btn-dark mt-2"
      >
        Add review
      </button>
    </div>
  </form>
)}

```

### Display Car Reviews

the `car.reviews` array and display each review as a paragraph element within the card.

```Solidity
<h5 className="card-title mt-5">Reviews</h5>
{car.reviews.map((c) => (
  <p className="card-text mt-2" key={c.postId}>
    Message: {c.reviewerMessage}
  </p>
))}

```

This code snippet maps over the `car.reviews` array and renders a paragraph element for each review. The `c` parameter represents an individual review object, and we extract the `reviewerMessage` property to display the review message.

### Export the Cars Component

At the end of the code, the `Cars` component is exported using `export default` so that it can be imported and used in other parts of the application.

```Solidity
export default Cars;

```

This allows other components to import the `Cars` component and use it in their render method.

That concludes the explanation of the `Cars` component. It displays a list of cars, along with their details and reviews. Users can like or dislike cars, add reviews, and see the number of likes and dislikes for each car.

### Import the Cars Component in App.js

To use the `Cars` component in the main `App.js` file, you need to import it. Add the following import statement at the top of the `App.js` file:

```Solidity
import { Cars } from './components/Cars';

```

This imports the `Cars` component from the `./components/Cars` file.

### Add the Cars Component to the Rendered JSX

Inside the `return` statement of the `App` component, add the `Cars` component as a child component to render it on the page. Update the JSX code as follows:

```Solidity
return (
  <div className="App">
    <NavigationBar cUSDBalance={cUSDBalance} />
    <Cars
      userWallet={address}
      Cars={car}
      addReview={addReview}
      buyCar={BuyCar}
      likeCar={likeCar}
      dislikeCar={dislikeCar}
    />
    <AddCar addCar={addCar} />
  </div>
);

```

Here, we pass various props to the `Cars` component:

-   `userWallet`: The address of the user's wallet.
-   `Cars`: The array of car objects.
-   `addReview`: The function to add a review to a car.
-   `buyCar`: The function to buy a car.
-   `likeCar`: The function to like a car.
-   `dislikeCar`: The function to dislike a car.

### Implement the AddCar Component

The `AddCar` component is responsible for rendering a form to add a new car to the car marketplace. It includes input fields for the car brand, model, image URL, price, and number of cars available. When the user clicks the "Add Car" button, the `addCar` function is called with the form values.

Here's the code for the `AddCar` component:

```Solidity
import React, { useState } from 'react';

export const AddCar = (props) => {
  const [brand, setBrand] = useState('');
  const [model, setModel] = useState('');
  const [image, setImage] = useState('');
  const [price, setPrice] = useState('');
  const [carsAvailable, setCarsAvailable] = useState('');

  const handleAddCar = () => {
    props.addCar(brand, model, image, price, carsAvailable);
    setBrand('');
    setModel('');
    setImage('');
    setPrice('');
    setCarsAvailable('');
  };

  return (
    <div>
      <form>
        <div className="form-row">
          <input
            type="text"
            className="form-control"
            value={brand}
            onChange={(e) => setBrand(e.target.value)}
            placeholder="Car Brand"
          />
          <input
            type="text"
            className="form-control mt-2"
            value={model}
            onChange={(e) => setModel(e.target.value)}
            placeholder="Car Model"
          />
          <input
            type="text"
            className="form-control mt-2"
            value={image}
            onChange={(e) => setImage(e.target.value)}
            placeholder="Image URL"
          />
          <input
            type="text"
            className="form-control mt-2"
            value={price}
            onChange={(e) => setPrice(e.target.value)}
            placeholder="Price"
          />
          <input
            type="text"
            className="form-control mt-2"
            value={carsAvailable}
            onChange={(e) => setCarsAvailable(e.target.value)}
            placeholder="Number of cars Available"
/>
<button
         type="button"
         onClick={handleAddCar}
         className="btn btn-dark mt-2"
       >
Add Car
</button>
</div>
</form>
</div>
);
};

```

In this code, we define multiple state variables using the `useState` hook to manage the input values for brand, model, image, price, and carsAvailable. The `handleAddCar` function is called when the "Add Car" button is clicked. It invokes the `addCar` function from the props and passes the form values as arguments. After adding the car, the input fields are reset to their initial values using the `setBrand`, `setModel`, `setImage`, `setPrice`, and `setCarsAvailable` functions.

### Implement the Cars Component

The `Cars` component is responsible for rendering the list of cars on the marketplace. It receives the car data as props and renders each car as a card. Users can interact with the cars by liking, disliking, adding reviews, and buying them.

Here's the code for the `Cars` component:

```Solidity
import React, { useState } from 'react';

export const Cars = (props) => {
  const [review, setReview] = useState('');

  const handleLikeCar = (index) => {
    props.likeCar(index);
  };

  const handleDislikeCar = (index) => {
    props.dislikeCar(index);
  };

  const handleAddReview = (index) => {
    props.addReview(index, review);
    setReview('');
  };

  const handleBuyCar = (index) => {
    props.buyCar(index);
  };

  return (
    <div className="card-container">
      {props.Cars.map((car) => (
        <div className="col-3">
          <div className="card" key={car.index}>
            <img
              className="card-img-top"
              src={car.image}
              alt="Card image cap"
            />
            <div className="card-body">
              <h5 className="card-title">Brand: {car.brand}</h5>
              <h6 className="card-subtitle">Model: {car.model}</h6>
              <h5 className="card-title">
                {car.carsAvailable} Cars Available
              </h5>
              <h2>Car Price: {car.price / 1000000000000000000} cUSD</h2>

              {props.userWallet !== car.owner && (
                <button
                  onClick={() => handleLikeCar(car.index)}
                  className="btn btn-success btn-b"
                >
                  Like
                </button>
              )}

              {props.userWallet !== car.owner && (
                <button
                  onClick={() => handleDislikeCar(car.index)}
                  className="btn btn-dark btn-b"
                >
                  Dislike
                </button>
              )}

              {props.userWallet !== car.owner && (
                <small className="int">
                  {car.likes} Likes {car.dislikes} Dislikes
                </small>
              )}

              {props.userWallet !== car.owner && (
                <form>
                  <div className="form-r">
                    <input
                      type="text"
                      className="form-control mt-4"
                      value={review}
                      onChange={(e) => setReview(e.target.value)}
                      placeholder="Enter review"
                    />
                    <button
                      type="button"
                      onClick={() => handleAddReview(car.index)}
                      className="btn btn-dark mt-2"
                    >
                      Add Review
                    </button>
                  </div>
                </form>
              )}

              <h5 className="card-title mt-5">Reviews</h5>
{car.reviews.map((review) => (
<p className="card-text mt-2" key={review.postId}>
Message: {review.reviewerMessage}
</p>
))}
</div>
</div>
</div>
))}
</div>
);
};

```

In this code, we iterate over the `Cars` array received as props and render each car as a card using the `map` function. Inside the card, we display the car's image, brand, model, number of cars available, and price. Users can like and dislike the car by clicking the corresponding buttons. If the user is not the owner of the car, they can add a review by entering a message and clicking the "Add Review" button.

The `handleLikeCar`, `handleDislikeCar`, `handleAddReview`, and `handleBuyCar` functions are responsible for invoking the respective functions passed as props. They take the car's index as an argument and perform the necessary action.

Finally, the car's reviews are displayed by iterating over the reviews array and rendering each review message as a paragraph.

### Update App.js to Use the Cars Component

In the `App` component, remove the existing code for rendering the cars and replace it with the `Cars` component. Pass the required props as shown below:

```Solidity
<Cars
  userWallet={address}
  Cars={car}
  addReview={addReview}
  buyCar={BuyCar}
  likeCar={likeCar}
  dislikeCar={dislikeCar}
/>

```

Here, we pass the `userWallet` address, the `car` array, and the functions `addReview`, `buyCar`, `likeCar`, and `dislikeCar` to the `Cars` component.

That's it! You have now implemented the `AddCar` and `Cars` components in your React application. The AddCar component allows users to add cars to the marketplace, and the `Cars` component displays the list of cars with various interactive features.

Feel free to customize the styling and add additional functionality to enhance the user experience.

### Add Styling to the Components

To enhance the visual appeal of the `AddCar` and `Cars` components, we can add some CSS styles. Create a new CSS file called `styles.css` in the `src` folder and add the following styles:

```Solidity
/* styles.css */

.card-container {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  margin-top: 20px;
}

.card {
  width: 250px;
  margin: 10px;
  border: 1px solid #ccc;
  border-radius: 5px;
  padding: 10px;
}

.card-img-top {
  width: 100%;
  height: 200px;
  object-fit: cover;
  border-radius: 5px;
}

.card-title {
  font-size: 18px;
  font-weight: bold;
}

.card-subtitle {
  color: #888;
  margin-top: 5px;
}

.card-body {
  padding-top: 10px;
}

.btn-b {
  margin-top: 10px;
  margin-right: 5px;
}

.int {
  margin-left: 10px;
  color: #888;
}

.form-r {
  margin-top: 10px;
}

.form-control {
  width: 100%;
}

.btn-dark {
  background-color: #343a40;
}

.btn-dark:hover {
  background-color: #23272b;
}

.mt-2 {
  margin-top: 2px;
}

.mt-4 {
  margin-top: 4px;
}

.mt-5 {
  margin-top: 5px;
}

.mb-5 {
  margin-bottom: 5px;
}

.text-danger {
  color: red;
}

.text-success {
  color: green;
}

```

Save the `styles.css` file and import it into the `App.js` file by adding the following line at the top:

```Solidity
import './styles.css';

```

Now, the styles defined in the `styles.css` file will be applied to the components.

### Test the Application

You can now test the application by running it in the development server. In the terminal, make sure you are in the project's root directory and run the following command:

```Solidity
npm start

```

This command starts the development server and opens the application in your default web browser. If the browser doesn't open automatically, you can manually navigate to `http://localhost:3000` to view the application.

Interact with the application by adding cars, liking and disliking cars, adding reviews, and buying cars. Verify that the changes are reflected in real-time and that the application functions as expected.

Congratulations! You have successfully implemented a car marketplace application using React and interacted with a smart contract on the Celo blockchain. You've learned how to connect to a Celo wallet, retrieve account balance, add cars, interact with car data, and perform transactions using smart contracts.

### NavigationBar.js

**React Navigation Bar Component**

In this tutorial, we'll be explaining the code for a React Navigation Bar component. The component is written using React functional components and is responsible for rendering a navigation bar with a brand name and a balance display.

Let's break down the code step by step:

### Importing Dependencies

```Solidity
import React from 'react';

```

In this line, we import the `React` library, which is necessary for writing React components.

### Creating the NavigationBar Component

```Solidity
export const NavigationBar = (props) => {
  return <div>
    {/* Navigation Bar JSX */}
  </div>;
};

```

Here, we define the `NavigationBar` component as a functional component. It receives `props` as its parameter, which allows us to pass data into the component from its parent component.

### Navigation Bar JSX

```Solidity
<nav className="navbar"> 
  <h1 className="brand-name">Car Companies Car Brands</h1>
  <nav>
    <span>
      <li><a className="balance"><span>{props.cUSDBalance}</span>cUSD</a></li>
    </span>
  </nav>
</nav>

```

Inside the `NavigationBar` component, we have the JSX code that represents the navigation bar. Let's examine it further:

-   `<nav className="navbar">`: This creates a navigation bar container with a CSS class name of "navbar".
-   `<h1 className="brand-name">Car Companies Car Brands</h1>`: This renders a heading element with the text "Car Companies Car Brands" and a CSS class name of "brand-name". It represents the brand name within the navigation bar.
-   `<nav>`: This nested `nav` element is used to create a secondary navigation section within the navigation bar.
-   `<span>`: This creates a span element to wrap the balance display.
-   `<li><a className="balance"><span>{props.cUSDBalance}</span>cUSD</a></li>`: This represents a list item (`li`) within the secondary navigation. It contains an anchor (`a`) element with a CSS class name of "balance". The `cUSDBalance` prop value is interpolated inside a span element, which will display the balance. The text "cUSD" represents the currency unit.

### Exporting the NavigationBar Component

```Solidity
export const NavigationBar = (props) => {
  // Component code
};

```

At the end of the file, we export the `NavigationBar` component so that it can be imported and used in other parts of our application.

That's it! You have successfully explained the given code, which is a React Navigation Bar component. You can now use this component in your React application to display a navigation bar with a brand name and balance information. Feel free to modify the CSS classes and add more functionality based on your requirements.

Remember to import the necessary dependencies and pass the required props to the `NavigationBar` component when using it in your application.

### Invoking the NavigationBar Component

To use the `NavigationBar` component in your application, you need to import it and invoke it within another component. Here's an example of how you can use it:

```Solidity
import React from 'react';
import { NavigationBar } from './NavigationBar';

const App = () => {
  const cUSDBalance = 100; // Example balance value
  
  return (
    <div>
      {/* Other components and content */}
      <NavigationBar cUSDBalance={cUSDBalance} />
      {/* Other components and content */}
    </div>
  );
};

export default App;

```

In this example, we import the `NavigationBar` component from the file it's defined in, which is assumed to be in the same directory (`./NavigationBar`). Then, within the `App` component, we render the `NavigationBar` component and pass it the `cUSDBalance` prop with a value of `100`.

By doing this, the `cUSDBalance` value is available inside the `NavigationBar` component as `props.cUSDBalance`, which can be used to display the balance in the navigation bar.

Remember to update the import and file paths based on your project's structure.

## Deployment

To deploy our smart contract successfully, we need the celo extention wallet which can be downloaded from [here](https://chrome.google.com/webstore/detail/celoextensionwallet/kkilomkmpmkbdnfelcpgckmpcaemjcdh?hl=en)

Next, we need to fund our newly created wallet which can done using the celo alfojares faucet [Here](https://celo.org/developers/faucet)

Now, click on the plugin logo at the bottom left corner and search for celo plugin.

Install the plugin and click on the celo logo which will show in the side tab after the plugin is installed.

Next connect your celo wallet, select the contract you want to deploy and finally click on deploy to deploy your contract.

## Conclusion

Let's summarize what we learned from this tutorial:

 - Solidity is a programming language used for writing smart contracts on the Ethereum blockchain.
- Solidity uses a similar syntax to JavaScript and C++, but has specific features such as the `contract` keyword and `msg.sender` that are unique to blockchain programming.
- We can use the `mapping` data structure in Solidity to create key-value pairs, which can be used to store and retrieve data.
- Solidity also allows us to define custom data types using the `struct` keyword, which allows us to create more complex data structures.

We hope this tutorial has provided a helpful introduction to Solidity and smart contract development. There is still much to learn and explore in this exciting field, but this is a solid foundation to build upon.

## Next Steps

With us coming to the end of this tutorial, I hope you've learned on how to build a Car Companies Smart Contract on the Celo Blockchain. Here are some relevant links that would aid your learning further.

- [Official Celo Docs](https://docs.celo.org/)
- [Official Solidity Docs](https://docs.soliditylang.org/en/v0.8.17/)
