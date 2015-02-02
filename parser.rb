class Traverser
  MAIL_DIRECTORY = File.join(Dir.pwd, 'datasets', 'maildir')
  ADDRESSES_PATH = File.join(Dir.pwd, 'addresses')
  CONVERSATIONS_PATH = File.join(Dir.pwd, 'conversations')

  @@emails = []
  @@addresses = []
  @@indices = {}

  @@addresses = File.readlines(ADDRESSES_PATH).map(&:chomp)[1..-1]

  def self.collect_email_addresses
    email_addresses = emails.each_with_object({}) do |email, addresses|
      addresses_in(email).each do |recipient|
        addresses[recipient] = true
      end
    end

    File.open(ADDRESSES_PATH, 'w') do |file|
      file.write("email\n")
      file.write(email_addresses.keys.join("\n"))
    end

    @@addresses = email_addresses.keys
  end

  def self.record_conversations
    # couldn't use Hash.new(Hash.new(0)) because ruby doesn't store keys
    @@convos = {}

    emails.each do |email|
      from = sender_of(email)
      to = recipients_of(email)
      next if from.empty? || to.empty?

      from.each do |sender|
        sender_index = index_of(sender)
        to.each do |recipient|
          recipient_index = index_of(recipient)

          if @@convos[sender_index]
            @@convos[sender_index][recipient_index] += 1
          else
            @@convos[sender_index] = Hash.new(0)
            @@convos[sender_index][recipient_index] += 1
          end
        end
      end
    end

    File.open(CONVERSATIONS_PATH, 'w') do |file|
      file.write("to,from,value\n")

      @@convos.each do |from, recipients|
        recipients.each do |recipient, value|
          file.write([recipient, from, value].join(',') + "\n")
        end
      end
    end
  end

  private

  def self.emails
    traverse(MAIL_DIRECTORY) if @@emails.empty?
    @@emails
  end

  def self.entries_under(directory)
    Dir.entries(directory).reject{ |entry| entry.match(/^\./) }
  end

  def self.traverse(directory)
    entries_under(directory).each do |entry|
      path = File.join(directory, entry)

      File.directory?(path) ? traverse(path) : @@emails << path
    end
  end

  def self.addresses_in(email)
    fields = encode(email).select do |line|
      line.match(/(^To|^From|^\\t.*@.*\\r\\n$)/)
    end

    fields.flat_map{ |field| parse_for_emails(field) }
  end

  def self.sender_of(email)
    fields = encode(email).select{ |line| line.match(/^To/) }

    fields.flat_map{ |field| parse_for_emails(field) }
  end

  def self.recipients_of(email)
    fields = encode(email).select{|line| line.match(/(^From|^\\t.*@.*\\r\\n$)/)}

    fields.flat_map{ |field| parse_for_emails(field) }
  end

  def self.encode(email)
    File.readlines(email).map do |line|
        line.encode!(
          'UTF-8', 'binary', invalid: :replace, undef: :replace, replace: ''
        )
    end
  end

  def self.parse_for_emails(field)
    field
      .strip
      .sub(/^To: |^From: /, '')
      .sub(/^\\t/, '')
      .gsub(/\[|\]|mailto:/, '')
      .gsub(/></, ', ')
      .gsub(/(<|>)/, '')
      .downcase
      .split(', ')
      .select{ |address| address.match(/@enron.com/) }
      .reject{ |address| address.match(/('|")/) }
      .reject{ |address| address.match(/\s/) }
      .map{|address| address.gsub(',', '')}
  end

  def self.index_of(address)
    @@indices[address] ||= @@addresses.index(address)
  end
end

Traverser.collect_email_addresses
Traverser.record_conversations
