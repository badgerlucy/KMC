$window_width = 640
$window_height = 480
window_size $window_width, $window_height

#ステージの左上
STAGE_X=40
STAGE_Y=40

#ブロックの大きさ
BLOCK_WIDTH=50
BLOCK_HEIGHT=50

#ブロックの個数
BLOCK_WIDTH_NUM=8
BLOCK_HEIGHT_NUM=8

#ブロックの種類数
BLOCK_NUM=7

#ブロックの消える個数
BLOCK_ERASE_NUM = 5

#ブロックの種類を返す関数
def block_select
    return rand(BLOCK_NUM)
end

#ブロックの初期化
$block = Array.new(BLOCK_WIDTH_NUM){Array.new(BLOCK_HEIGHT_NUM)}

BLOCK_WIDTH_NUM.times do |i|
    BLOCK_HEIGHT_NUM.times do |j|
        $block[i][j] = block_select
    end 
end

#枠が表示されてるか
isWaku=false

#枠の座標
wakuX=0
wakuY=0

#枠の大きさ
WAKU_WIDTH=60
WAKU_HEIGHT=60

#fpsをセット
set_fps(30)

#アニメーションのフレームの管理
count = 0

#ゲームオーバーのフレームの管理
count_gameover = 0

#情報座標
INFO_X = 480
INFO_Y = 40
INFO_H = 40

#block_connected用の探索済みを管理
$block_searched= Array.new(BLOCK_WIDTH_NUM){Array.new(BLOCK_HEIGHT_NUM)}

#ブロックのつながってる個数
def block_connected(x,y)
    
    #自分を探索済みにする
    $block_searched[x][y]=true

    #ブロックがつながった個数
    sum = 1

    #上
    if y!= 0
        if $block[x][y] == $block[x][y-1] && !$block_searched[x][y-1]
            sum += block_connected(x, y-1)
        end    
    end
    
    #下
    if y!= BLOCK_HEIGHT_NUM-1
        if $block[x][y] == $block[x][y+1] && !$block_searched[x][y+1]
            sum += block_connected(x, y+1)
        end    
    end

    #左
    if x!= 0
        if $block[x][y] == $block[x-1][y] && !$block_searched[x-1][y]
            sum += block_connected(x-1, y)
        end    
    end
    
    #右
    if x!= BLOCK_WIDTH_NUM-1
        if $block[x][y] == $block[x+1][y] && !$block_searched[x+1][y]
            sum += block_connected(x+1, y)
        end    
    end

    return sum
end

#消すブロックの関数
$block_erased= Array.new(BLOCK_WIDTH_NUM){Array.new(BLOCK_HEIGHT_NUM)}


#ブロックを消す関数
def block_erase(x,y)


    #自分を消去する
    $block_erased[x][y]=true

    #上
    if y!= 0
        if $block[x][y] == $block[x][y-1] && !$block_erased[x][y-1]
            block_erase(x,y-1)
        end
   end

    #下
    if y!= BLOCK_HEIGHT_NUM-1
        if $block[x][y] == $block[x][y+1] && !$block_erased[x][y+1]
            block_erase(x,y+1)
        end
   end

   #左
    if x!= 0
        if $block[x][y] == $block[x-1][y] && !$block_erased[x-1][y]
            block_erase(x-1,y)
        end
   end

   #右
    if x!= BLOCK_WIDTH_NUM - 1
        if $block[x][y] == $block[x+1][y] && !$block_erased[x+1][y]
            block_erase(x+1,y)
        end
   end
end

#時間
time_start = Time.now
time_finish = 60

#スコア
score = 0

#ゲームオーバー
gameover = false

#シーン
scene = 1

set_title("ブロック崩し")

mainloop do
    clear_window

    case scene
    when 1
        set_fontsize(80)
        text("ブロック崩し", x:100, y:100, color: WHITE)
        text("CLICK TO START", x:50, y:200, color: WHITE)
     
        if mousebutton_click?(1)
            scene = 2

            time_start = Time.now
            #スコア
            score = 0
            isWaku = false
            #枠の座標   
            wakuX=0
            wakuY=0
            count = 0
            count_gameover = 0
            gameover = false

           while true
            BLOCK_WIDTH_NUM.times do |i|
            BLOCK_HEIGHT_NUM.times do |j|
                $block[i][j] = block_select
                end 
            end

            BLOCK_WIDTH_NUM.times do |i|
                BLOCK_HEIGHT_NUM.times do |j|
                    $block_searched[i][j]=false
                end
            end

            flag = false
            BLOCK_WIDTH_NUM.times do |i|
                BLOCK_HEIGHT_NUM.times do |j|
                    if !$block_searched[i][j]
                        connected_num = block_connected(i,j)
                        if connected_num>=BLOCK_ERASE_NUM
                            flag = true
                        end                   
                    end 
                end
            end
            if flag == true
                next
            else
                break
            end

        end
        

    end


    when 2   
        if !gameover
            #クリックされたら
            #ブロックスワップ
            if mousebutton_click?(1)
                #ステージをクリックしたら
                if (STAGE_X <= mouse_x && mouse_x <= STAGE_X + BLOCK_WIDTH*BLOCK_WIDTH_NUM) &&
                    (STAGE_Y <= mouse_y && mouse_y <= STAGE_Y + BLOCK_HEIGHT*BLOCK_HEIGHT_NUM)
                    #枠が表示されたら
                    if isWaku
                        swapX = (mouse_x - STAGE_X)/BLOCK_WIDTH
                        swapY = (mouse_y - STAGE_Y)/BLOCK_HEIGHT  
                        #枠の上下左右をクリックしたらスワップ
                        if  (wakuX == swapX && wakuY == swapY + 1)||
                            (wakuX == swapX && wakuY == swapY - 1)||
                            (wakuX == swapX + 1 && wakuY == swapY)||
                            (wakuX == swapX - 1 && wakuY == swapY)

                            $block[wakuX][wakuY],$block[swapX][swapY] = $block[swapX][swapY],$block[wakuX][wakuY]
                        end
                        #それ以外なら枠が消える
                        isWaku = false
                else
                    #枠が表示されてなかったら
                    #枠を表示
                        wakuX = (mouse_x - STAGE_X)/BLOCK_WIDTH                
                        wakuY = (mouse_y - STAGE_Y)/BLOCK_HEIGHT    
                        isWaku=true            
                    end
                else
                    #ステージ外をクリックしたら
                    #枠を消す
                    isWaku=false
                end
            end


        #$block_erasedの初期化
            BLOCK_WIDTH_NUM.times do |i|
                BLOCK_HEIGHT_NUM.times do |j|
                    $block_erased[i][j]=false
                end
            end

        #$block_searchedの初期化
            BLOCK_WIDTH_NUM.times do |i|
                BLOCK_HEIGHT_NUM.times do |j|
                    $block_searched[i][j]=false
                end
            end
            

            #ブロック消す
            BLOCK_WIDTH_NUM.times do |i|
                BLOCK_HEIGHT_NUM.times do |j|
                    if !$block_searched[i][j]
                        connected_num = block_connected(i,j)
                        #スコア増やす
                        if connected_num>=BLOCK_ERASE_NUM
                            score += connected_num ** 2
                            block_erase(i,j)
                        end                   
                    end 
                end
            end

        #実際にブロックを消す
            BLOCK_WIDTH_NUM.times do |i|
                BLOCK_HEIGHT_NUM.times do |j|
                    if $block_erased[i][j]
                        $block[i][j] = -1
                    end    
                end
            end

            #ブロックを落とす
            BLOCK_WIDTH_NUM.times do |i|
                (BLOCK_HEIGHT_NUM - 1).downto 0 do |j|
                    if $block[i][j]!=-1
                        #落とした回数
                            k = 0
                        while $block[i][j+k+1] == -1
                            $block[i][j+k], $block[i][j+k+1] = $block[i][j+k+1], $block[i][j+k]
                            k += 1
                            if j+k == BLOCK_HEIGHT_NUM - 1
                                break
                            end
                        end
                    end            
                end
            end

            #ブロックを補充
            BLOCK_WIDTH_NUM.times do |i|
                BLOCK_HEIGHT.times do |j|
                    if  $block[i][0] == -1
                        $block[i][0] = block_select
                    end
                end
            end
        end
            
            
            #ブロックの表示
            BLOCK_WIDTH_NUM.times do |i|
                BLOCK_HEIGHT_NUM.times do |j|
                    case $block[i][j]
                    when 0
                        put_image("red.png", x:STAGE_X+BLOCK_WIDTH*i, y:STAGE_Y+BLOCK_HEIGHT*j, w:BLOCK_WIDTH, h:BLOCK_HEIGHT, colorkey:true)
                    when 1
                        put_image("yellow.png", x:STAGE_X+BLOCK_WIDTH*i, y:STAGE_Y+BLOCK_HEIGHT*j, w:BLOCK_WIDTH, h:BLOCK_HEIGHT, colorkey:true)
                    when 2
                        put_image("orange.png", x:STAGE_X+BLOCK_WIDTH*i, y:STAGE_Y+BLOCK_HEIGHT*j, w:BLOCK_WIDTH, h:BLOCK_HEIGHT, colorkey:true)
                    when 3
                        put_image("green.png", x:STAGE_X+BLOCK_WIDTH*i, y:STAGE_Y+BLOCK_HEIGHT*j, w:BLOCK_WIDTH, h:BLOCK_HEIGHT, colorkey:true)
                    when 4
                        put_image("blue.png", x:STAGE_X+BLOCK_WIDTH*i, y:STAGE_Y+BLOCK_HEIGHT*j, w:BLOCK_WIDTH, h:BLOCK_HEIGHT, colorkey:true)
                    when 5
                        put_image("purple.png", x:STAGE_X+BLOCK_WIDTH*i, y:STAGE_Y+BLOCK_HEIGHT*j, w:BLOCK_WIDTH, h:BLOCK_HEIGHT, colorkey:true)
                    when 6
                        put_image("pink.png", x:STAGE_X+BLOCK_WIDTH*i, y:STAGE_Y+BLOCK_HEIGHT*j, w:BLOCK_WIDTH, h:BLOCK_HEIGHT, colorkey:true)
                    end    
                end 
            end

            #枠のアニメの管理
            count += 1
            if count >= 30
                count -= 30
            end

            #枠の表示
            if isWaku
                case count
                when 0..14
                    put_image("frame1.png", x:STAGE_X+BLOCK_WIDTH*wakuX-(WAKU_WIDTH-BLOCK_WIDTH)/2, y:STAGE_Y+BLOCK_HEIGHT*wakuY-(WAKU_HEIGHT-BLOCK_HEIGHT)/2, w:WAKU_WIDTH, h:WAKU_HEIGHT, colorkey:true )
                when 15..29
                    put_image("frame2.png", x:STAGE_X+BLOCK_WIDTH*wakuX-(WAKU_WIDTH-BLOCK_WIDTH)/2, y:STAGE_Y+BLOCK_HEIGHT*wakuY-(WAKU_HEIGHT-BLOCK_HEIGHT)/2, w:WAKU_WIDTH, h:WAKU_HEIGHT, colorkey:true )
                end
            end

            #時間の管理
            time = Time.now - time_start

            time = (time* (10 ** 2)).round/(10.0 ** 2)

            if time_finish - time <= 0
                gameover = true
                time = time_finish
            end
            
            set_fontsize(24)
            text("TIME", x: INFO_X, y: INFO_Y+INFO_H*0, color: WHITE)
            text("#{time_finish - time}", x: INFO_X, y: INFO_Y+INFO_H*1, color: WHITE)    

            text("SCORE", x: INFO_X, y: INFO_Y+INFO_H*3, color: WHITE)
            text("#{score}", x: INFO_X, y: INFO_Y+INFO_H*4, color: WHITE)

            if gameover
                set_fontsize(120)
                text("TIME UP!!", x:50, y:150, color: WHITE)
                count_gameover += 1
                if count_gameover >= 100
                    scene = 3
                end
            end
            
    when 3
        set_fontsize(64)
        text("GAME OVER", x:170, y:100, color: WHITE)        
        text("SCORE : #{score}", x:170, y:200, color: WHITE)
        text("CLICK TO RESTART", x:80, y:300, color: WHITE) 
        if mousebutton_click?(1)
            scene = 1
        end
    end

end
