
# Puerta

[![Build Status](https://travis-ci.org/channainfo/puerta.svg?branch=develop)](https://travis-ci.org/channainfo/puerta)

Puerta is a  payment gateway gem specifically built in [BookMeBus](https://bookmebus.com) for its usages in BookMeBus SaaS and BookMeBus platform.

It composes of many local and international payments that works well in ASEAN region or to be more precisely in Cambodia, Vietnam and Thailand.

## Why Puerta?
Most payment gateway that works well lack of ruby libs, mostly available in PHP and Java. Migrating from PHP or Java to Ruby is hard, Puerta aims to make your life easier.

## Why we open source this?
To make our tech community vibrant we need to make the ecosystem easy and friendly. We believe this piece of software will help improve the implementation and technicality behind to help boost the e-commerce building easier and more professional.


## Installation
```ruby
gem 'puerta'

```

And then execute:

```bash  
$ bundle
```


Or install it yourself as:


```bash
$ gem install puerta
```


## Usage

### Configure gem
Puerta has two modes of environment ( **sandbox** and **production**). You can configure the gem with the following:
```ruby
Puerta.configure do |config|
  config.env = 'production' # available value: sandbox, production
 end
```
**sanbox** is the default one.

### Nganluong
Nganluong is one of the biggest payment gateway in VN. They have good documentation of the integration in PHP. Its PHP docs can be found [here](https://www.nganluong.vn/en/integrate/advanced.html).

> This gem provide a port from NL official to ruby world. Most of the concept you might need to read from the official docs. There will be mayor similarity and a bit different in API due to the different in nature between ruby and php. We aims to make everything as similar as official libs.

#### Request user to payment page

```ruby
merchant_params ={
  merchant_id: '47792',
  merchant_password: '2a349ed1ff2658bfe793628405bbfa89',
  receiver_email: 'merchant@yopmail.com',
  cur_code: 'usd'
}
type = 'ATM_ONLINE'
checkout = Puerta::Nl::Checkout.new(type, merchant_params)

payment_options = {
      order_code: 'my_order_id',
      order_description: 'SiemReap tour - 3 days',
      buyer_fullname: 'Jose antonio',
      buyer_email: 'joseantonio@travelasia.com',
      buyer_mobile: '+34701234133',
      buyer_address: 'Samdech Techo Hun Sen Park Phnom Penh Cambodia, 120101, Cambodia',
      total_amount: 12,
      bank_code: 'EXB',
      return_url: 'https://mydomain/return_callback',
      cancel_url: 'https://mydomain/cancel_callback'
    }

result = Puerta::Nl::Checkout(payment_options)

#Response look like this
{:token=>"156785-29e2e2f3b34fdab01726d1f53bacf8e5",
:error_code=>"00",
:error_message=>"Thành công",
:time_limit=>"1568794311",
:description=>"",
:checkout_url=>"https://sandbox.nganluong.vn:8088/nl35/checkout/version31/index/token_code/156785-29e2e2f3b34fdab01726d1f53bacf8e5" }
```
you can use the **result[:checkout_url]** to redirect to the payment. You can do this with many forms from example:

 1. Redirect from the server side with redirect_to result[:checkout_url]
 2. Send back to client and let client direct it with javascript
 3. Put in the form and then auto submit it with form GET method.

#### Validate the payment after user perform transaction :

```ruby
result = checkout.get_transaction_detail(token)
#result look like this:
{:error_code=>"00",
:error_message=>"Thành công",
:token=>"156801-ca796b81909b6160c5db7c50ee9baf36",
:transaction_id=>"156801-ca796b81909b6160c5db7c50ee9baf36",
:transaction_status=>"00",
:bank_code=>"EXB"}
```
### Other useful method in NL
```ruby
result = Puerta::Nl::Checkout.payment_types
# result looks like this
expected = {
  "ATM_ONLINE"=>{
    :BIDV=>{:title=>"Ngân hàng TMCP Đầu tư & Phát triển Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]}}},
 "VISA"=>{
   :VISA=>{:title=>"Visa", :type=>["VISA"]},
   :MASTER=>{:title=>"Master", :type=>["VISA"]}},
"ATM_OFFLINE"=>{
  :BIDV=>{:title=>"Ngân hàng TMCP Đầu tư & Phát triển Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
  :VCB=>{:title=>"Ngân hàng TMCP Ngoại Thương Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
  :DAB=>{:title=>"Ngân hàng Đông Á", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},


checkout.ok? # boolean
checkout.error_code # string nl error code
checkout.error_message # string nl errror message(vi)
```
## Other payments
OjO: coming soon!

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/channainfo/puerta](https://github.com/channainfo/puerta). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
