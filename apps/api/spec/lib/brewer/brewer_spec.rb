# require './lib/brewer/brewer'

# describe Brewer do
#   describe ':initialize' do
#     it 'initialises correctly' do
#       _ = Brewer.new
#     end
#   end

#   describe ':search' do
#     it 'finds nothing' do
#       brewer = Brewer.new

#       found = brewer.search(['zzz'])
#       expect(found).to eq ''
#     end

#     it 'finds something' do
#       brewer = Brewer.new
#       found = brewer.search(%w[v Privacy])
#       expect(found).to eq %w[Neovim Dev-HTTP Dev-Go Privacy Dev-All].join("\n")
#     end

#     it 'is missing terms' do
#       brewer = Brewer.new
#       expect { brewer.search([]) }.to raise_error(ArgumentError)
#     end
#   end

#   describe ':list' do
#     it 'lists the Brewfiles' do
#       brewer = Brewer.new

#       listed = brewer.list
#       expect(listed).to eq "All\nNeovim\nDev-HTTP\nPython\nDev-Go\nPrivacy\nVim\nDNS\nDev-All\nCore"
#     end
#   end

#   describe ':generate' do
#     it 'generates a Brewfile' do
#       brewer = Brewer.new

#       brewfile = brewer.generate(%w[Neovim Privacy])
#       expect(brewfile).to eq "brew tap neovim/neovim \nbrew install neovim \nbrew install privoxy"
#     end

#     it 'is missing terms' do
#       brewer = Brewer.new
#       expect { brewer.generate([]) }.to raise_error(ArgumentError)
#     end
#   end
# end

# describe ':strip_ext' do
#   it 'strips the extension' do
#     expect(strip_ext('Dev.Brewfile')).to eq 'Dev'
#   end
# end

# # TODO: :entry_to_s
