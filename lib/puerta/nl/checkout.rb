module Puerta
  module Nl
    class Checkout

      VERSION = '3.1'
      TYPES = [ 'ATM_ONLINE', 'IB_ONLINE', 'VISA', 'ATM_OFFLINE', 'NH_OFFLINE', 'NL', 'CREDIT_CARD_PREPAID', ]

      BANK_CODES = {
        BIDV: { title: "Ngân hàng TMCP Đầu tư & Phát triển Việt Nam", type: ['ATM_ONLINE', 'IB_ONLINE', 'ATM_OFFLINE', 'NH_OFFLINE'] },
        VCB: { title: "Ngân hàng TMCP Ngoại Thương Việt Nam", type: ['ATM_ONLINE', 'IB_ONLINE', 'ATM_OFFLINE', 'NH_OFFLINE'] },
        DAB: { title: "Ngân hàng Đông Á", type: ['ATM_ONLINE', 'IB_ONLINE', 'ATM_OFFLINE', 'NH_OFFLINE'] },
        TCB: { title: "Ngân hàng Kỹ Thương", type: ['ATM_ONLINE', 'IB_ONLINE', 'ATM_OFFLINE', 'NH_OFFLINE'] },
        MB: { title: "Ngân hàng Quân Đội", type: ['ATM_ONLINE', 'ATM_OFFLINE', 'NH_OFFLINE'] },
        VIB: { title: "Ngân hàng Quốc tế", type: ['ATM_ONLINE', 'NH_OFFLINE'] },
        ICB: { title: "Ngân hàng Công Thương Việt Nam", type: ['ATM_ONLINE', 'ATM_OFFLINE', 'NH_OFFLINE'] },
        EXB: { title: "Ngân hàng Xuất Nhập Khẩu", type: ['ATM_ONLINE'] },
        ACB: { title: "Ngân hàng Á Châu", type: ['ATM_ONLINE', 'ATM_OFFLINE', 'NH_OFFLINE'] },
        HDB: { title: "Ngân hàng Phát triển Nhà TPHCM", type: ['ATM_ONLINE'] },
        MSB: { title: "Ngân hàng Hàng Hải", type: ['ATM_ONLINE', 'ATM_OFFLINE', 'NH_OFFLINE'] },
        NVB: { title: "Ngân hàng Nam Việt", type: ['ATM_ONLINE'] },
        VAB: { title: "Ngân hàng Việt Á", type: ['ATM_ONLINE'] },
        VPB: { title: "Ngân Hàng Việt Nam Thịnh Vượng", type: ['ATM_ONLINE'] },
        SCB: { title: "Ngân hàng Sài Gòn Thương tín", type: ['ATM_ONLINE', 'ATM_OFFLINE', 'NH_OFFLINE'] },
        PGB: { title: "Ngân hàng Xăng dầu Petrolimex", type: ['ATM_ONLINE', 'ATM_OFFLINE', 'NH_OFFLINE'] },
        GPB: { title: "Ngân hàng TMCP Dầu khí Toàn Cầu", type: ['ATM_ONLINE'] },
        AGB: { title: "Ngân hàng Nông nghiệp & Phát triển nông thôn", type: ['ATM_ONLINE', 'ATM_OFFLINE', 'NH_OFFLINE'] },
        SGB: { title: "Ngân hàng Sài Gòn Công Thương", type: ['ATM_ONLINE'] },
        BAB: { title: "Ngân hàng Bắc Á", type: ['ATM_ONLINE'] },
        TPB: { title: "Tền phong bank", type: ['ATM_ONLINE', 'NH_OFFLINE'] },
        NAB: { title: "Ngân hàng Nam Á", type: ['ATM_ONLINE'] },
        SHB: { title: "Ngân hàng TMCP Sài Gòn - Hà Nội (SHB)", type: ['ATM_ONLINE', 'ATM_OFFLINE'] },
        OJB: { title: "Ngân hàng TMCP Đại Dương (OceanBank)", type: ['ATM_ONLINE'] },
        VISA: {title: "Visa", type: ['VISA'] },
        MASTER: {title: "Master", type: ['VISA'] },
      }

      MODE = {
        production: {
          host: 'https://www.nganluong.vn',
          endpoint: '/checkout.api.nganluong.post.php',
        },
        sandbox: {
          host: 'https://sandbox.nganluong.vn:8088',
          endpoint: '/nl35/checkout.api.nganluong.post.php',
        }
      }

      attr_accessor :type

      # merchant_id = '';
      # merchant_password = '';
      # receiver_email = '';
      # cur_code = 'vnd';
      def initialize(type, options={})
        raise "Invalid type: #{type} in #{Checkout::TYPES}" if !Checkout::TYPES.include?(type)

        @type    = type
        @options = options
      end

      def host
        if Puerta.config.sandbox?
          Checkout::MODE[:sandbox][:host]
        elsif Puerta.config.production?
          Checkout::MODE[:production][:host]
        end
      end

      def endpoint
        if Puerta.config.sandbox?
          Checkout::MODE[:sandbox][:endpoint]
        elsif Puerta.config.production?
          Checkout::MODE[:production][:endpoint]
        end
      end

      def self.payment_types
        result = {}
        TYPES.each do |payment_type|
          result[payment_type] = Checkout::BANK_CODES.reject {|k,v|  !v[:type].include?(payment_type)}
        end
        result
      end

      def payment_methods
        Checkout::BANK_CODES.reject {|k,v|  !v[:type].include?(@type)}
      end

      def query(token)
        params = {
          merchant_id: @options[:merchant_id],
          merchant_password: Digest::MD5.hex(@options[:merchant_password]),
          version: VERSION,
          function: 'GetTransactionDetail',
          token:token
        }

        connection = Faraday::Connection.new host, ssl: { verify: false }

        response = connection.post do |req|
          req.url endpoint
          req.body = params
        end

        response
      end

      def require_params
        [ 'merchant_id', 'merchant_password', 'version', 'function', 'receiver_email', 'order_code', 'total_amount', 'payment_method' ]
      end

      # @card_options:
      # $order_code,$total_amount,$payment_type,$order_description,$tax_amount, $fee_shipping,
      # $discount_amount,$return_url,$cancel_url,$buyer_fullname,$buyer_email,$buyer_mobile,
  		# $buyer_address,$array_items,$bank_code
      # bank_code: ( VISA, CREDIT_CARD_PREPAID, ATM_ONLINE, ATM_OFFLINE)
      # no bank code: ( NH_OFFLINE, NL, IB_ONLINE )
      def payment_options(card_options)
        card_options[:array_items] ||= []

        params = {
          function: 'SetExpressCheckout',
          version: Checkout::VERSION,
          payment_method: @type,
          merchant_password: Digest::MD5.hexdigest(@options[:merchant_password]),
          total_item: card_options[:array_items].count
        }


        params = params.merge(@options.select{|k,v| [:cur_code, :receiver_email, :merchant_id].include?(k)})
        params = params.merge(card_options.select{|k,v| k != :array_items } )

        sending_params = params.reject{|k,v| v == nil || v == ''}

        if(card_options[:array_items] && card_options[:array_items].count > 0)
          card_options[:array_items].each do |item|
            item.each do |key, value|
              sending_params[key] = value
            end
          end
        end
        sending_params
      end

      def call(card_options)
        params = payment_options(card_options)

        connection = Faraday::Connection.new host, ssl: { verify: false }

        response = connection.post do |req|
          req.url endpoint
          req.body = params
        end

        response
      end

      def error_message(error_code)
        errors = {
  				'00' => 'Thành công',
  				'99' => 'Lỗi chưa xác minh',
  				'06' => 'Mã merchant không tồn tại hoặc bị khóa',
  				'02' => 'Địa chỉ IP truy cập bị từ chối',
  				'03' => 'Mã checksum không chính xác, truy cập bị từ chối',
  				'04' => 'Tên hàm API do merchant gọi tới không hợp lệ (không tồn tại)',
  				'05' => 'Sai version của API',
  				'07' => 'Sai mật khẩu của merchant',
  				'08' => 'Địa chỉ email tài khoản nhận tiền không tồn tại',
  				'09' => 'Tài khoản nhận tiền đang bị phong tỏa giao dịch',
  				'10' => 'Mã đơn hàng không hợp lệ',
  				'11' => 'Số tiền giao dịch lớn hơn hoặc nhỏ hơn quy định',
  				'12' => 'Loại tiền tệ không hợp lệ',
  				'29' => 'Token không tồn tại',
  				'80' => 'Không thêm được đơn hàng',
  				'81' => 'Đơn hàng chưa được thanh toán',
  				'110' => 'Địa chỉ email tài khoản nhận tiền không phải email chính',
  				'111' => 'Tài khoản nhận tiền đang bị khóa',
  				'113' => 'Tài khoản nhận tiền chưa cấu hình là người bán nội dung số',
  				'114' => 'Giao dịch đang thực hiện, chưa kết thúc',
  				'115' => 'Giao dịch bị hủy',
  				'118' => 'tax_amount không hợp lệ',
  				'119' => 'discount_amount không hợp lệ',
  				'120' => 'fee_shipping không hợp lệ',
  				'121' => 'return_url không hợp lệ',
  				'122' => 'cancel_url không hợp lệ',
  				'123' => 'items không hợp lệ',
  				'124' => 'transaction_info không hợp lệ',
  				'125' => 'quantity không hợp lệ',
  				'126' => 'order_description không hợp lệ',
  				'127' => 'affiliate_code không hợp lệ',
  				'128' => 'time_limit không hợp lệ',
  				'129' => 'buyer_fullname không hợp lệ',
  				'130' => 'buyer_email không hợp lệ',
  				'131' => 'buyer_mobile không hợp lệ',
  				'132' => 'buyer_address không hợp lệ',
  				'133' => 'total_item không hợp lệ',
  				'134' => 'payment_method, bank_code không hợp lệ',
  				'135' => 'Lỗi kết nối tới hệ thống ngân hàng',
  				'140' => 'Đơn hàng không hỗ trợ thanh toán trả góp'
        }
        errors[error_code]
      end

    end
  end
end
