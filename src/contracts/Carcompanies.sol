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


    function addCar(
        string memory _brand,
        string memory _model,
        string memory _image,
        uint _price,
        uint _carsAvailable
    )public{
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
    }

    function getCar(uint _index)public view returns(
        address payable,
        string memory,
        string memory,
        string memory,
        uint,
        uint,
        uint,
        uint,
        uint,
        Review[] memory
    ){
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

    // like the car
    function likeCar(uint _index)public{
        require(cars[_index].owner != msg.sender);
        cars[_index].likes++;
    }

    // leave a dislike for the car
    function dislikeCar(uint _index)public{
         require(cars[_index].owner != msg.sender);
        cars[_index].dislikes++;
    }

       // add a revie to a book
   function addReview(uint _index, string memory _reviews) public{
     require(cars[_index].owner != msg.sender);
    reviewsMap[_index].push(Review(_index, address(msg.sender), _reviews));
    cars[_index].numberOfreview++;
  }


function buyCar(uint _index) public payable  {
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
    }

    //acquiring length of cars
    function getCarLength() public view returns (uint){
        return (carLength);
    }

    // acquiring length of reviews 
    function getReviewsLength(uint _index) public view returns (uint) {
        return reviewsMap[_index].length;
    }
} 