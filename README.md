# TokenField
Swift rewrite of VENTokenField. Functions nearly identically to VENTokenField.

Installation
------------
The easiest way to get started is to use [CocoaPods](http://cocoapods.org/). Just add the following line to your Podfile:

```ruby
pod 'TokenField', '~> 0.1.2'
```

Usage
-----

If you've ever used a ```UITableView```, using ```TokenField``` should be a breeze.

Similar to ```UITableView```, ```TokenField``` provides two protocols: ```<TokenFieldDelegate>``` and ```<TokenFieldDataSource>```.

### TokenFieldDelegate
This protocol notifies you when things happen in the token field that you might want to know about.

* ```tokenField:didEnterText:``` is called when a user hits the return key on the input field.
* ```tokenField:didDeleteTokenAtIndex:``` is called when a user deletes a token at a particular index.
* ```tokenField:didChangeText:``` is called when a user changes the text in the input field.
* ```tokenFieldDidBeginEditing:``` is called when the input field becomes first responder.

### TokenFieldDataSource
This protocol allows you to provide info about what you want to present in the token field.

Implement...
* ```tokenField:titleForTokenAtIndex:``` to specify what the title for the token at a particular index should be.
* ```numberOfTokensInTokenField:``` to specify how many tokens you have.
* ```tokenFieldCollapsedText:``` to specify what you want the token field to say in the collapsed state.
