require 'spec_helper'

RSpec.describe Puerta::Nl::Checkout do

  let!(:options) do
    {
      merchant_id: '47792',
      merchant_password: '2a349ed1ff2658bfe793628405bbfa89',
      receiver_email: 'merchant@yopmail.com',
      cur_code: 'vnd'
    }
  end


  describe "#get_transaction_detail" do
    context "with valid params" do
      it "return result with transaction" do
        checkout = Puerta::Nl::Checkout.new('ATM_ONLINE', options)
        url = "#{checkout.host}#{checkout.endpoint}"

        params = {
          "function"=>"GetTransactionDetail",
          "merchant_id"=>"47792",
          "merchant_password"=>"ab594de9d42caaf1b71b53e35a87b3ed",
          "token"=>"156801-ca796b81909b6160c5db7c50ee9baf36",
          "version"=>"3.1"
        }

        success = "
        <?xml version=\"1.0\" encoding=\"UTF-8\" ?>
        <result>
          <error_code>00</error_code>
          <token>156801-ca796b81909b6160c5db7c50ee9baf36</token>
          <description></description>
          <transaction_status>00</transaction_status>
          <receiver_email>nhant@peacesoft.net</receiver_email>
          <order_code>E9LoYf6xIWdOUwXh</order_code>
          <total_amount>500000</total_amount>
          <payment_method>ATM_ONLINE</payment_method>
          <bank_code>EXB</bank_code>
          <payment_type>1</payment_type>
          <order_description>BookMeBus</order_description>
          <tax_amount>0</tax_amount>
          <discount_amount>0</discount_amount>
          <fee_shipping>0</fee_shipping>
          <return_url>http%3A%2F%2Flocalhost%3A8080%2Ftransit%2Fgateway_nl_callbacks%2Freturn</return_url>
          <cancel_url>http%3A%2F%2Flocalhost%3A8080%2Ftransit%2Fgateway_nl_callbacks%2Freturn</cancel_url>
          <buyer_fullname>kimsan</buyer_fullname>
          <buyer_email>kimsanlim27@gmail.com</buyer_email>
          <buyer_mobile>+85570801395</buyer_mobile>
          <buyer_address>Phnom Penh</buyer_address>
          <affiliate_code></affiliate_code>
          <transaction_id>19698950</transaction_id>
        </result>
        "

        stub_request(:post, url).with(body: params).to_return(status: 200, body: success, headers: {})
        result = checkout.get_transaction_detail('156801-ca796b81909b6160c5db7c50ee9baf36')

        expect(result).to match :error_code=>"00",
                                :error_message=>"Thành công",
                                :token=>"156801-ca796b81909b6160c5db7c50ee9baf36",
                                :transaction_id=>"156801-ca796b81909b6160c5db7c50ee9baf36",
                                :transaction_status=>"00",
                                :bank_code=>"EXB"


      end
    end

    context "with invalid params" do
      it "return result with error" do
        checkout = Puerta::Nl::Checkout.new('ATM_ONLINE', options)
        url = "#{checkout.host}#{checkout.endpoint}"

        params = {
          "function"=>"GetTransactionDetail",
          "merchant_id"=>"47792",
          "merchant_password"=>"ab594de9d42caaf1b71b53e35a87b3ed",
          "token"=>"156801-ca796b81909b6160c5db7c50ee9baf36",
          "version"=>"3.1"
        }

        success = "
        <?xml version=\"1.0\" encoding=\"UTF-8\" ?>
        <result>
          <error_code>99</error_code>
          <token></token>
          <description></description>
          <transaction_status>99</transaction_status>
          <receiver_email>nhant@peacesoft.net</receiver_email>
          <order_code>E9LoYf6xIWdOUwXh</order_code>
          <total_amount>500000</total_amount>
          <payment_method></payment_method>
          <bank_code></bank_code>
          <payment_type>1</payment_type>
          <order_description></order_description>
          <tax_amount>0</tax_amount>
          <discount_amount>0</discount_amount>
          <fee_shipping>0</fee_shipping>
          <return_url>http%3A%2F%2Flocalhost%3A8080%2Ftransit%2Fgateway_nl_callbacks%2Freturn</return_url>
          <cancel_url>http%3A%2F%2Flocalhost%3A8080%2Ftransit%2Fgateway_nl_callbacks%2Freturn</cancel_url>
          <buyer_fullname>kimsan</buyer_fullname>
          <buyer_email>kimsanlim27@gmail.com</buyer_email>
          <buyer_mobile>+85570801395</buyer_mobile>
          <buyer_address>Phnom Penh</buyer_address>
          <affiliate_code></affiliate_code>
          <transaction_id></transaction_id>
        </result>
        "

        stub_request(:post, url).with(body: params).to_return(status: 200, body: success, headers: {})
        result = checkout.get_transaction_detail('156801-ca796b81909b6160c5db7c50ee9baf36')

        expect(result).to match :error_code=>"99",
                                :error_message=>"Lỗi chưa xác minh",
                                :token=>"",
                                :transaction_id=>"",
                                :transaction_status=>"99",
                                :bank_code=>""

      end
    end
  end


  describe "#call" do
    context 'with valid request payloads' do
      it 'return result with token' do
        checkout = Puerta::Nl::Checkout.new('ATM_ONLINE', options)
        url = "#{checkout.host}#{checkout.endpoint}"

        params = {
          "cur_code"=>"vnd",
          "function"=>"SetExpressCheckout",
          "merchant_id"=>"47792",
          "merchant_password"=>"ab594de9d42caaf1b71b53e35a87b3ed",
          "payment_method"=>"ATM_ONLINE",
          "receiver_email"=>"merchant@yopmail.com",
          "total_item"=>"0",
          "version"=>"3.1"
        }

        checkout_response = "
        <?xml version=\"1.0\" encoding=\"UTF-8\" ?>
          <result>
            <error_code>00</error_code>
            <token>156785-29e2e2f3b34fdab01726d1f53bacf8e5</token>
            <description></description>
            <time_limit>1568794311</time_limit>
            <checkout_url>https://sandbox.nganluong.vn:8088/nl35/checkout/version31/index/token_code/156785-29e2e2f3b34fdab01726d1f53bacf8e5</checkout_url>
          </result>
        "

        stub_request(:post, url).with(body: params).to_return(status: 200, body: checkout_response, headers: {})

        card_options = {}
        result = checkout.call(card_options)

        expect(result).to match  :token=>"156785-29e2e2f3b34fdab01726d1f53bacf8e5",
                                 :error_code=>"00",
                                 :error_message=>"Thành công",
                                 :time_limit=>"1568794311",
                                 :description=>"",
                                 :checkout_url=>"https://sandbox.nganluong.vn:8088/nl35/checkout/version31/index/token_code/156785-29e2e2f3b34fdab01726d1f53bacf8e5"

      end
    end

    context 'with invalid request payloads' do
      it 'return result with error' do
        checkout = Puerta::Nl::Checkout.new('ATM_ONLINE', options)
        url = "#{checkout.host}#{checkout.endpoint}"

        params = {
          "cur_code"=>"vnd",
          "function"=>"SetExpressCheckout",
          "merchant_id"=>"47792",
          "merchant_password"=>"ab594de9d42caaf1b71b53e35a87b3ed",
          "payment_method"=>"ATM_ONLINE",
          "receiver_email"=>"merchant@yopmail.com",
          "total_item"=>"0",
          "version"=>"3.1"
        }

        checkout_response = "
        <?xml version=\"1.0\" encoding=\"UTF-8\" ?>
          <result>
            <error_code>99</error_code>
            <token></token>
            <description></description>
            <time_limit>1568794311</time_limit>
            <checkout_url>https://sandbox.nganluong.vn:8088/nl35/checkout/version31/index/token_code/156785-29e2e2f3b34fdab01726d1f53bacf8e5</checkout_url>
          </result>
        "

        stub_request(:post, url).with(body: params).to_return(status: 200, body: checkout_response, headers: {})

        card_options = {}
        result = checkout.call(card_options)
        expect(result).to match :token=>"",
                                 :error_code=>"99",
                                 :error_message=>"Lỗi chưa xác minh",
                                 :time_limit=>"1568794311",
                                 :description=>"",
                                 :checkout_url=>"https://sandbox.nganluong.vn:8088/nl35/checkout/version31/index/token_code/156785-29e2e2f3b34fdab01726d1f53bacf8e5"
      end
    end


  end

  describe ".payment_types" do
    it "return a hash of payment_type along with its payment methods" do
      result = Puerta::Nl::Checkout.payment_types
      expected = {
        "ATM_ONLINE"=>{
          :BIDV=>{:title=>"Ngân hàng TMCP Đầu tư & Phát triển Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :VCB=>{:title=>"Ngân hàng TMCP Ngoại Thương Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :DAB=>{:title=>"Ngân hàng Đông Á", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :TCB=>{:title=>"Ngân hàng Kỹ Thương", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :MB=>{:title=>"Ngân hàng Quân Đội", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :VIB=>{:title=>"Ngân hàng Quốc tế", :type=>["ATM_ONLINE", "NH_OFFLINE"]},
          :ICB=>{:title=>"Ngân hàng Công Thương Việt Nam", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :EXB=>{:title=>"Ngân hàng Xuất Nhập Khẩu", :type=>["ATM_ONLINE"]},
          :ACB=>{:title=>"Ngân hàng Á Châu", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :HDB=>{:title=>"Ngân hàng Phát triển Nhà TPHCM", :type=>["ATM_ONLINE"]},
          :MSB=>{:title=>"Ngân hàng Hàng Hải", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :NVB=>{:title=>"Ngân hàng Nam Việt", :type=>["ATM_ONLINE"]},
          :VAB=>{:title=>"Ngân hàng Việt Á", :type=>["ATM_ONLINE"]},
          :VPB=>{:title=>"Ngân Hàng Việt Nam Thịnh Vượng", :type=>["ATM_ONLINE"]},
          :SCB=>{:title=>"Ngân hàng Sài Gòn Thương tín", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :PGB=>{:title=>"Ngân hàng Xăng dầu Petrolimex", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :GPB=>{:title=>"Ngân hàng TMCP Dầu khí Toàn Cầu", :type=>["ATM_ONLINE"]},
          :AGB=>{:title=>"Ngân hàng Nông nghiệp & Phát triển nông thôn", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :SGB=>{:title=>"Ngân hàng Sài Gòn Công Thương", :type=>["ATM_ONLINE"]},
          :BAB=>{:title=>"Ngân hàng Bắc Á", :type=>["ATM_ONLINE"]},
          :TPB=>{:title=>"Tền phong bank", :type=>["ATM_ONLINE", "NH_OFFLINE"]},
          :NAB=>{:title=>"Ngân hàng Nam Á", :type=>["ATM_ONLINE"]},
          :SHB=>{:title=>"Ngân hàng TMCP Sài Gòn - Hà Nội (SHB)", :type=>["ATM_ONLINE", "ATM_OFFLINE"]},
          :OJB=>{:title=>"Ngân hàng TMCP Đại Dương (OceanBank)", :type=>["ATM_ONLINE"]}},
        "IB_ONLINE"=>{
          :BIDV=>{:title=>"Ngân hàng TMCP Đầu tư & Phát triển Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :VCB=>{:title=>"Ngân hàng TMCP Ngoại Thương Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :DAB=>{:title=>"Ngân hàng Đông Á", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :TCB=>{:title=>"Ngân hàng Kỹ Thương", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]}},
       "VISA"=>{
         :VISA=>{:title=>"Visa", :type=>["VISA"]},
         :MASTER=>{:title=>"Master", :type=>["VISA"]}},
      "ATM_OFFLINE"=>{
        :BIDV=>{:title=>"Ngân hàng TMCP Đầu tư & Phát triển Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :VCB=>{:title=>"Ngân hàng TMCP Ngoại Thương Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :DAB=>{:title=>"Ngân hàng Đông Á", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :TCB=>{:title=>"Ngân hàng Kỹ Thương", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :MB=>{:title=>"Ngân hàng Quân Đội", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :ICB=>{:title=>"Ngân hàng Công Thương Việt Nam", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :ACB=>{:title=>"Ngân hàng Á Châu", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :MSB=>{:title=>"Ngân hàng Hàng Hải", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :SCB=>{:title=>"Ngân hàng Sài Gòn Thương tín", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :PGB=>{:title=>"Ngân hàng Xăng dầu Petrolimex", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :AGB=>{:title=>"Ngân hàng Nông nghiệp & Phát triển nông thôn", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :SHB=>{:title=>"Ngân hàng TMCP Sài Gòn - Hà Nội (SHB)", :type=>["ATM_ONLINE", "ATM_OFFLINE"]}},
      "NH_OFFLINE"=>{
        :BIDV=>{:title=>"Ngân hàng TMCP Đầu tư & Phát triển Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :VCB=>{:title=>"Ngân hàng TMCP Ngoại Thương Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :DAB=>{:title=>"Ngân hàng Đông Á", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :TCB=>{:title=>"Ngân hàng Kỹ Thương", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :MB=>{:title=>"Ngân hàng Quân Đội", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :VIB=>{:title=>"Ngân hàng Quốc tế", :type=>["ATM_ONLINE", "NH_OFFLINE"]},
        :ICB=>{:title=>"Ngân hàng Công Thương Việt Nam", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :ACB=>{:title=>"Ngân hàng Á Châu", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :MSB=>{:title=>"Ngân hàng Hàng Hải", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :SCB=>{:title=>"Ngân hàng Sài Gòn Thương tín", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :PGB=>{:title=>"Ngân hàng Xăng dầu Petrolimex", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :AGB=>{:title=>"Ngân hàng Nông nghiệp & Phát triển nông thôn", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
        :TPB=>{:title=>"Tền phong bank", :type=>["ATM_ONLINE", "NH_OFFLINE"]}},
      "NL"=>{},
      "CREDIT_CARD_PREPAID"=>{} }

      expect(result).to eq expected
    end
  end

  describe '#parse_xml' do
    it 'return' do
      checkout = Puerta::Nl::Checkout.new('ATM_ONLINE', {})
      xml_string = "
      <?xml version=\"1.0\" encoding=\"UTF-8\" ?>
        <result>
          <error_code>00</error_code>
          <token>156785-29e2e2f3b34fdab01726d1f53bacf8e5</token>
          <description></description>
          <time_limit>1568794311</time_limit>
          <checkout_url>https://sandbox.nganluong.vn:8088/nl35/checkout/version31/index/token_code/156785-29e2e2f3b34fdab01726d1f53bacf8e5</checkout_url>
        </result>
      "
     doc = checkout.parse_xml(xml_string)
     expect(doc.at('result/checkout_url').text).to eq "https://sandbox.nganluong.vn:8088/nl35/checkout/version31/index/token_code/156785-29e2e2f3b34fdab01726d1f53bacf8e5"

    end
  end

  describe "#host" do
    context 'with sanbox env' do
      it 'return https://sandbox.nganluong.vn:8088' do
        Puerta.reset_config
        checkout = Puerta::Nl::Checkout.new('ATM_ONLINE', {})
        expect(checkout.host).to eq 'https://sandbox.nganluong.vn:8088'
      end
    end

    context 'with production env' do
      it 'return https://sandbox.nganluong.vn:8088' do
        Puerta.reset_config
        Puerta.configure do |config|
          config.env = :production
        end

        checkout = Puerta::Nl::Checkout.new('ATM_ONLINE', {})
        expect(checkout.host).to eq 'https://www.nganluong.vn'
      end
    end

  end

  describe "#endpoint" do
    context 'with sanbox env' do
      it 'return /nl35/checkout.api.nganluong.post.php' do
        Puerta.reset_config
        checkout = Puerta::Nl::Checkout.new('ATM_ONLINE', {})
        expect(checkout.endpoint).to eq '/nl35/checkout.api.nganluong.post.php'
      end
    end

    context 'with production env' do
      it 'return /checkout.api.nganluong.post.php' do
        Puerta.reset_config
        Puerta.configure do |config|
          config.env = :production
        end

        checkout = Puerta::Nl::Checkout.new('ATM_ONLINE', {})
        expect(checkout.endpoint).to eq '/checkout.api.nganluong.post.php'
      end
    end

  end


  it "return 3.1 checkout version" do
    expect(Puerta::Nl::Checkout::VERSION).to eq '3.1'
  end

  it "support the following types: 'VISA', 'CREDIT_CARD_PREPAID', 'ATM_ONLINE', 'ATM_OFFLINE', 'NH_OFFLINE', 'ATM_ONLINE', 'NL', 'IB_ONLINE'" do
    expect(Puerta::Nl::Checkout::TYPES).to eq ["ATM_ONLINE", "IB_ONLINE", "VISA", "ATM_OFFLINE", "NH_OFFLINE", "NL", "CREDIT_CARD_PREPAID"]
  end

  describe '#payment_methods' do
    context 'ATM_ONLINE' do
      it 'return options for ATM_ONLINE only' do
        type   = 'ATM_ONLINE'
        puerta = Puerta::Nl::Checkout.new(type, {})

        result = puerta.payment_methods

        expected = {
          :BIDV=>{:title=>"Ngân hàng TMCP Đầu tư & Phát triển Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :VCB=>{:title=>"Ngân hàng TMCP Ngoại Thương Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :DAB=>{:title=>"Ngân hàng Đông Á", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :TCB=>{:title=>"Ngân hàng Kỹ Thương", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :MB=>{:title=>"Ngân hàng Quân Đội", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :VIB=>{:title=>"Ngân hàng Quốc tế", :type=>["ATM_ONLINE", "NH_OFFLINE"]},
          :ICB=>{:title=>"Ngân hàng Công Thương Việt Nam", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :EXB=>{:title=>"Ngân hàng Xuất Nhập Khẩu", :type=>["ATM_ONLINE"]},
          :ACB=>{:title=>"Ngân hàng Á Châu", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :HDB=>{:title=>"Ngân hàng Phát triển Nhà TPHCM", :type=>["ATM_ONLINE"]},
          :MSB=>{:title=>"Ngân hàng Hàng Hải", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :NVB=>{:title=>"Ngân hàng Nam Việt", :type=>["ATM_ONLINE"]},
          :VAB=>{:title=>"Ngân hàng Việt Á", :type=>["ATM_ONLINE"]},
          :VPB=>{:title=>"Ngân Hàng Việt Nam Thịnh Vượng", :type=>["ATM_ONLINE"]},
          :SCB=>{:title=>"Ngân hàng Sài Gòn Thương tín", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :PGB=>{:title=>"Ngân hàng Xăng dầu Petrolimex", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :GPB=>{:title=>"Ngân hàng TMCP Dầu khí Toàn Cầu", :type=>["ATM_ONLINE"]},
          :AGB=>{:title=>"Ngân hàng Nông nghiệp & Phát triển nông thôn", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :SGB=>{:title=>"Ngân hàng Sài Gòn Công Thương", :type=>["ATM_ONLINE"]},
          :BAB=>{:title=>"Ngân hàng Bắc Á", :type=>["ATM_ONLINE"]},
          :TPB=>{:title=>"Tền phong bank", :type=>["ATM_ONLINE", "NH_OFFLINE"]},
          :NAB=>{:title=>"Ngân hàng Nam Á", :type=>["ATM_ONLINE"]},
          :SHB=>{:title=>"Ngân hàng TMCP Sài Gòn - Hà Nội (SHB)", :type=>["ATM_ONLINE", "ATM_OFFLINE"]},
          :OJB=>{:title=>"Ngân hàng TMCP Đại Dương (OceanBank)", :type=>["ATM_ONLINE"]}
        }

        expect(result).to match expected
      end
    end

    context 'IB_ONLINE' do
      it 'return options for VISA only' do
        type   = 'IB_ONLINE'
        puerta = Puerta::Nl::Checkout.new(type, {})

        result = puerta.payment_methods
        expected = {
          :BIDV=>{:title=>"Ngân hàng TMCP Đầu tư & Phát triển Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :VCB=>{:title=>"Ngân hàng TMCP Ngoại Thương Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :DAB=>{:title=>"Ngân hàng Đông Á", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :TCB=>{:title=>"Ngân hàng Kỹ Thương", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]}
        }

        expect(result).to match expected
      end
    end

    context 'VISA' do
      it 'return options for VISA only' do
        type   = 'VISA'
        puerta = Puerta::Nl::Checkout.new(type, {})

        result = puerta.payment_methods
        expected = { VISA: { :title=>"Visa", :type=>["VISA"] }, :MASTER=> {:title=>"Master", :type=>["VISA"]} }

        expect(result).to match expected
      end
    end

    context 'ATM_OFFLINE' do
      it 'return options for ATM_OFFLINE only' do
        type   = 'ATM_OFFLINE'
        puerta = Puerta::Nl::Checkout.new(type, {})

        result = puerta.payment_methods
        expected = {
          :BIDV=>{:title=>"Ngân hàng TMCP Đầu tư & Phát triển Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :VCB=>{:title=>"Ngân hàng TMCP Ngoại Thương Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :DAB=>{:title=>"Ngân hàng Đông Á", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :TCB=>{:title=>"Ngân hàng Kỹ Thương", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :MB=>{:title=>"Ngân hàng Quân Đội", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :ICB=>{:title=>"Ngân hàng Công Thương Việt Nam", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :ACB=>{:title=>"Ngân hàng Á Châu", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :MSB=>{:title=>"Ngân hàng Hàng Hải", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :SCB=>{:title=>"Ngân hàng Sài Gòn Thương tín", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :PGB=>{:title=>"Ngân hàng Xăng dầu Petrolimex", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :AGB=>{:title=>"Ngân hàng Nông nghiệp & Phát triển nông thôn", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :SHB=>{:title=>"Ngân hàng TMCP Sài Gòn - Hà Nội (SHB)", :type=>["ATM_ONLINE", "ATM_OFFLINE"]}
        }

        expect(result).to match expected
      end
    end

    context 'NH_OFFLINE' do
      it 'return options for VISA only' do
        type   = 'NH_OFFLINE'
        puerta = Puerta::Nl::Checkout.new(type, {})

        result = puerta.payment_methods

        expected = {
          :BIDV=>{:title=>"Ngân hàng TMCP Đầu tư & Phát triển Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :VCB=>{:title=>"Ngân hàng TMCP Ngoại Thương Việt Nam", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :DAB=>{:title=>"Ngân hàng Đông Á", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :TCB=>{:title=>"Ngân hàng Kỹ Thương", :type=>["ATM_ONLINE", "IB_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :MB=>{:title=>"Ngân hàng Quân Đội", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :VIB=>{:title=>"Ngân hàng Quốc tế", :type=>["ATM_ONLINE", "NH_OFFLINE"]},
          :ICB=>{:title=>"Ngân hàng Công Thương Việt Nam", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :ACB=>{:title=>"Ngân hàng Á Châu", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :MSB=>{:title=>"Ngân hàng Hàng Hải", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :SCB=>{:title=>"Ngân hàng Sài Gòn Thương tín", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :PGB=>{:title=>"Ngân hàng Xăng dầu Petrolimex", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :AGB=>{:title=>"Ngân hàng Nông nghiệp & Phát triển nông thôn", :type=>["ATM_ONLINE", "ATM_OFFLINE", "NH_OFFLINE"]},
          :TPB=>{:title=>"Tền phong bank", :type=>["ATM_ONLINE", "NH_OFFLINE"]}
        }

        expect(result).to match expected

      end
    end

    context 'NL' do
      it 'return options for NL only' do
        type   = 'NL'
        puerta = Puerta::Nl::Checkout.new(type, {})

        result = puerta.payment_methods
        expected = {}

        expect(result).to match(expected)
      end
    end

    context 'CREDIT_CARD_PREPAID' do
      it 'return options for CREDIT_CARD_PREPAID only' do
        type   = 'CREDIT_CARD_PREPAID'
        puerta = Puerta::Nl::Checkout.new(type, {})

        result = puerta.payment_methods
        expected = {}

        expect(result).to match expected
      end
    end

  end

  describe "#payment_options" do
    before(:each) do
      type = 'IB_ONLINE'

      options = {
        host: 'https://sandbox.nganluong.vn:8088',
        end_point: '/nl35/checkout.api.nganluong.post.php',
        merchant_id: '47792',
        merchant_password: '2a349ed1ff2658bfe793628405bbfa89',
        receiver_email: 'merchant@yopmail.com',
        cur_code: 'vnd'
      }
      @puerta = Puerta::Nl::Checkout.new(type, options)
    end
    context "Without items" do
      it 'return options without item' do
        card_options = {
          order_code: 'order-xxxx',
          total_amount: 100000,
          bank_code: 'BIDV',
          return_url: 'http://staging.bookmebus.com/return_url',
          cancel_url: 'http://staging.bookmebus.com/cancel_url',
          buyer_fullname:	'Tên người mua hàng',
          buyer_email: 'trung@bookmebus.com',
          buyer_mobile: '03612345678',
          buyer_address: 'Địa chỉ người mua hàng',
        }
        result = @puerta.payment_options(card_options)

        expected = {
          :function=>"SetExpressCheckout",
          :version=>"3.1",
          :payment_method=>"IB_ONLINE",
          :merchant_password=>"ab594de9d42caaf1b71b53e35a87b3ed",
          :total_item=>0,
          :merchant_id=>"47792",
          :receiver_email=>"merchant@yopmail.com",
          :cur_code=>"vnd",
          :order_code=>"order-xxxx",
          :bank_code=> 'BIDV',
          return_url: 'http://staging.bookmebus.com/return_url',
          cancel_url: 'http://staging.bookmebus.com/cancel_url',
          buyer_fullname:	'Tên người mua hàng',
          buyer_email: 'trung@bookmebus.com',
          buyer_mobile: '03612345678',
          buyer_address: 'Địa chỉ người mua hàng',
          :total_amount=>100000
        }
        expect(result).to match expected

      end
    end

    context "With array items" do
      it 'return options along with its items' do
        card_options = {
          order_code: 'order-xxxx',
          total_amount: 100000,
          bank_code: 'BIDV',
          return_url: 'http://staging.bookmebus.com/return_url',
          cancel_url: 'http://staging.bookmebus.com/cancel_url',
          buyer_fullname:	'Tên người mua hàng',
          buyer_email: 'trung@bookmebus.com',
          buyer_mobile: '03612345678',
          buyer_address: 'Địa chỉ người mua hàng',
          array_items: [
            { "PP-SR": 2 },
            { "SR-PP": 2 }
          ]
        }
        result = @puerta.payment_options(card_options)

        expected = {
          :function=>"SetExpressCheckout",
          :version=>"3.1",
          :payment_method=>"IB_ONLINE",
          :merchant_password=>"ab594de9d42caaf1b71b53e35a87b3ed",
          :total_item=>2,
          :merchant_id=>"47792",
          :receiver_email=>"merchant@yopmail.com",
          :cur_code=>"vnd",
          :order_code=>"order-xxxx",
          :total_amount=>100000,
          :bank_code=> 'BIDV',
          return_url: 'http://staging.bookmebus.com/return_url',
          cancel_url: 'http://staging.bookmebus.com/cancel_url',
          buyer_fullname:	'Tên người mua hàng',
          buyer_email: 'trung@bookmebus.com',
          buyer_mobile: '03612345678',
          buyer_address: 'Địa chỉ người mua hàng',
          :"PP-SR"=>2,
          :"SR-PP"=>2
        }

        expect(result).to match expected

      end
    end
  end

end
