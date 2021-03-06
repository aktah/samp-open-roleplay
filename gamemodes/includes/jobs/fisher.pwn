
#include <YSI_Coding\y_hooks>

#define DELIVERY_FISH_X     2475.2932
#define DELIVERY_FISH_Y     -2710.7759
#define DELIVERY_FISH_Z     3.1963

new FishingPlace[MAX_PLAYERS];
new FishingCP[MAX_PLAYERS];
new FishingBoat[MAX_PLAYERS];

new const Float:GoFishingPlace[3][3] = {
	{813.6824,-2248.2407,-0.4488},
	{407.6824,-2318.2407,-0.5752},
	{-25.9471,-1981.9995,-0.6268}
};

new const FishNames[5][20] = {
	"��ҷٹ��",
	"������͹",
	"��ҡ��ⷧ�Һ",
	"������������",
	"��ҩ���"
};

hook OnPlayerConnect(playerid) {
    FishingCP[playerid] = 0;
    FishingPlace[playerid] = -1;
    FishingBoat[playerid] = 0;
}

CMD:fishhelp(playerid, params[])
{
    SendClientMessage(playerid, COLOR_DARKGREEN,"_______________________________________");
	SendClientMessage(playerid, COLOR_GRAD3,"/myfish /gofishing /fish /stopfishing /unloadfish");
	return 1;
}

CMD:gofishing(playerid, params[]) {

    new place;
	if(sscanf(params,"i", place)) {
        SendClientMessage(playerid, COLOR_GRAD1, "�����: /gofishing [1(������)/2(�ҡ�оҹ)]");
        return 1;
    }

    if (FishingPlace[playerid] != -1) {
        return SendClientMessage(playerid, COLOR_LIGHTRED, "�س�� �社���/��áԨ ����");
    }

    if (place == 1) {

        new vehicleid = GetPlayerVehicleID(playerid);
        if (vehicleid == INVALID_VEHICLE_ID || !IsABoat(vehicleid) || !vehicleData[vehicleid][eVehicleDBID] || vehicleData[vehicleid][eVehicleOwnerDBID] != playerData[playerid][pDBID]) {
            SendClientMessage(playerid, COLOR_LIGHTRED, "�س��ͧ���� �/��� ���ͧ͢�س������ҹ");
            return 1;
        }
        else {
            vehicleid = GetNearestVehicle(playerid);
            if (vehicleid == INVALID_VEHICLE_ID || !IsABoat(vehicleid) || !vehicleData[vehicleid][eVehicleDBID] || vehicleData[vehicleid][eVehicleOwnerDBID] != playerData[playerid][pDBID]) {
                SendClientMessage(playerid, COLOR_LIGHTRED, "�س��ͧ���� �/��� ���ͧ͢�س������ҹ");
                return 1;
            }
        }

        if(playerData[playerid][pFishes] > 5000) {
            SendClientMessage(playerid, COLOR_DARKGREEN, "�س����Ҿ�����");
            SendClientMessage(playerid, COLOR_DARKGREEN, "/unloadfish �ҡ�س��ͧ��â�»�Ңͧ�س");
            return 1;
        }

        new rand = random(sizeof(GoFishingPlace));
        if (IsPlayerInRangeOfPoint(playerid, 30.0, GoFishingPlace[rand][0],GoFishingPlace[rand][1],GoFishingPlace[rand][2])) {
            FishingPlace[playerid] = 1;
            SendClientMessage(playerid, COLOR_WHITE, "���������������� (/fish) ����������������س /stopfishing ��� /unloadfish");
            DisablePlayerCheckpoint(playerid);
        }
        else {
            SetPlayerCheckpoint(playerid, GoFishingPlace[rand][0],GoFishingPlace[rand][1],GoFishingPlace[rand][2], 30.0);
            SendClientMessage(playerid, COLOR_DARKGREEN, "价��ش�����������ط�������������� (/fish)");
        }
        
        FishingCP[playerid] = rand + 1;
        return 1;
    }
    else if (place == 2) {

	    if(playerData[playerid][pFishes] > 1000) {
	        SendClientMessage(playerid, COLOR_DARKGREEN, "����Ҿ�����");
	        SendClientMessage(playerid, COLOR_DARKGREEN, "/unloadfish �ҡ�س��ͧ��â�»�Ңͧ�س");
            return 1;
	    }

        if (!IsPlayerInRangeOfPoint(playerid, 30.0, 383.6021,-2061.7881,7.6140))
        {
            SetPlayerCheckpoint(playerid, 383.6021,-2061.7881,7.6140, 30.0);
            SendClientMessage(playerid, COLOR_DARKGREEN, "价��ش�����������ط�������������� (/fish)");
        }
        else 
        {
            FishingPlace[playerid] = 2;
            SendClientMessage(playerid, COLOR_WHITE, "���������������� (/fish) ����������������س /stopfishing ��� /unloadfish");
        }
        FishingCP[playerid] = sizeof(GoFishingPlace) + 1;
        return 1;
    }
    else {
        SendClientMessage(playerid, COLOR_GRAD1, "�����: /gofishing [1(������)/2(�ҡ�оҹ)]");
    }
    return 1;
}

hook OnPlayerEnterCheckpoint(playerid) {
    if (FishingCP[playerid] != 0) {
        if (FishingCP[playerid] <= sizeof(GoFishingPlace)) { // ����
            new rand = FishingCP[playerid]-1;
            if (IsPlayerInRangeOfPoint(playerid, 30.0, GoFishingPlace[rand][0],GoFishingPlace[rand][1],GoFishingPlace[rand][2])) {
                FishingPlace[playerid] = 1;

                SendClientMessage(playerid, COLOR_WHITE, "���������������� (/fish) ����������������س /stopfishing ��� /unloadfish");
                DisablePlayerCheckpoint(playerid);
            }
        }
        else {
            if (IsPlayerInRangeOfPoint(playerid, 30.0, 383.6021,-2061.7881,7.6140)) { // �оҹ LS
                FishingPlace[playerid] = 2;

                SendClientMessage(playerid, COLOR_WHITE, "���������������� (/fish) ����������������س /stopfishing ��� /unloadfish");
                DisablePlayerCheckpoint(playerid);
            }
            else if (IsPlayerInRangeOfPoint(playerid, 2.5, DELIVERY_FISH_X,DELIVERY_FISH_Y,DELIVERY_FISH_Z) && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) { // ��»�� LS
                new earn = playerData[playerid][pFishes] + random(floatround(playerData[playerid][pFishes]/5));
  
                GiveMoney(playerid, earn);
                GameTextForPlayer(playerid, sprintf("~p~SOLD FISHES WEIGHT ~w~%d FOR %d", playerData[playerid][pFishes], earn), 8000, 4);

                playerData[playerid][pFishes] = 0;
                FishingCP[playerid] = 0;
                DisablePlayerCheckpoint(playerid);
            }
        }
        return -2; // ��ش Callback ���
    }
    return 1;
}

CMD:stopfishing(playerid, params[]) {
	if(FishingPlace[playerid] != -1)
	{
	    SendClientMessage(playerid, COLOR_DARKGREEN, "�س��ش���������");

	    if(playerData[playerid][pFishes]) 
            SendClientMessage(playerid, COLOR_DARKGREEN, "/unloadfish �ҡ�س��ͧ��â�»�Ңͧ�س");

	    FishingPlace[playerid]=-1;
        FishingCP[playerid] = 0;
	}
	else SendClientMessage(playerid, COLOR_WHITE, "�س�ѧ����鵡���");
	return 1;
}

CMD:unloadfish(playerid, params[]) {

    if(FishingPlace[playerid] != -1)
		return SendClientMessage(playerid, COLOR_LIGHTRED, "��ش����ҡ�͹���ѹ�Ѻ�á /stopfishing");

	if(playerData[playerid][pFishes])
	{
	    SendClientMessage(playerid, COLOR_DARKGREEN, "ʶҹ�������Ѻ���觻������Ѻ�Թ�١������ͧ������麹Ἱ���");
        SetPlayerCheckpoint(playerid, DELIVERY_FISH_X,DELIVERY_FISH_Y,DELIVERY_FISH_Z, 2.0);
        FishingCP[playerid] = sizeof(GoFishingPlace) + 1;

	} else SendClientMessage(playerid, COLOR_LIGHTRED, "�س����ջ��");
	
    return 1;
}

CMD:myfish(playerid, params[]) {
	if(playerData[playerid][pFishes])
	{
	    SendClientMessage(playerid, COLOR_DARKGREEN, "_______________________________________");
	    SendClientMessageEx(playerid, COLOR_DARKGREEN, "���˹ѡ��� [%d] �͹��", playerData[playerid][pFishes]);
	} 
    else SendClientMessage(playerid, COLOR_LIGHTRED, "�س����ջ��");
	
    return 1;
}

CMD:fish(playerid, params[]) {

	if(FishingPlace[playerid] != -1) {
		if(!HasCooldown(playerid,COOLDOWN_FISHING))
		{
            new Fishcaught, Fishlbs;
            SetCooldown(playerid,COOLDOWN_FISHING, 6);

            if (FishingCP[playerid] != 0) {
                if (FishingCP[playerid] <= sizeof(GoFishingPlace)) { // ����
                    new rand = FishingCP[playerid]-1;
                    if (IsPlayerInRangeOfPoint(playerid, 30.0, GoFishingPlace[rand][0],GoFishingPlace[rand][1],GoFishingPlace[rand][2])) {
                          
                        new vehicleid = GetPlayerVehicleID(playerid);
                        if (vehicleid == INVALID_VEHICLE_ID || !IsABoat(vehicleid) || !vehicleData[vehicleid][eVehicleDBID] || vehicleData[vehicleid][eVehicleOwnerDBID] != playerData[playerid][pDBID]) {
                            SendClientMessage(playerid, COLOR_LIGHTRED, "�س��ͧ���� �/��� ���ͧ͢�س������ҹ");
                            return 1;
                        }
                        else {
                            vehicleid = GetNearestVehicle(playerid);
                            if (vehicleid == INVALID_VEHICLE_ID || !IsABoat(vehicleid) || !vehicleData[vehicleid][eVehicleDBID] || vehicleData[vehicleid][eVehicleOwnerDBID] != playerData[playerid][pDBID]) {
                                SendClientMessage(playerid, COLOR_LIGHTRED, "�س��ͧ���� �/��� ���ͧ͢�س������ҹ");
                                return 1;
                            }
                        }

                        if(random(6) >= 5)
                            return SendClientMessageEx(playerid, COLOR_LIGHTRED, "�س�Ѻ������������");
    
                        Fishcaught = random(5);

                        if(FishingPlace[playerid] != 1) Fishlbs = ((Fishcaught+1)*10) + (1 + random(10));
                        else Fishlbs = ((Fishcaught+1)*20) + (1 + random(10));

                        SendNearbyMessage(playerid, 20.0, COLOR_PURPLE, "%s �͡��ǹ�ѹ�索������о���Ҿǡ�ҨѺ%s��", ReturnRealName(playerid), FishNames[Fishcaught]);
                        SendClientMessageEx(playerid, COLOR_DARKGREEN, "�س�Ѻ%s %d �͹��", FishNames[Fishcaught], Fishlbs);
        
                        playerData[playerid][pFishes]+=Fishlbs;

                        if(playerData[playerid][pFishes] > 5000)
                        {
                            FishingPlace[playerid]=-1;

                            SendClientMessage(playerid, COLOR_DARKGREEN, "����Ҿ�����");
                            SendClientMessage(playerid, COLOR_DARKGREEN, "/unloadfish �ҡ�س��ͧ��â�»�Ңͧ�س");
                            return 1;
                        }

                        FishingBoat[playerid]+=Fishlbs;

                        if(FishingBoat[playerid] > 1000) {
                            rand = random(sizeof(GoFishingPlace));
                            SetPlayerCheckpoint(playerid, GoFishingPlace[rand][0],GoFishingPlace[rand][1],GoFishingPlace[rand][2], 30.0);
                            FishingCP[playerid] = rand + 1;
                            FishingBoat[playerid]=0;
                            FishingPlace[playerid]=-1;
                            SendClientMessage(playerid, COLOR_DARKGREEN, "仵�����ʶҹ������");
                        }
                    }
                    else SendClientMessage(playerid, COLOR_LIGHTRED, "�س����ҷ���������");
                }
                else {
                    if (IsPlayerInRangeOfPoint(playerid, 30.0, 383.6021,-2061.7881,7.6140)) { // �оҹ
                        if(random(7) >= 5)
                            return SendClientMessageEx(playerid, COLOR_LIGHTRED, "�س�Ѻ������������");
    
                        Fishcaught = random(5);

                        if(FishingPlace[playerid] != 1) Fishlbs = ((Fishcaught+1)*10) + (1 + random(10));
                        else Fishlbs = ((Fishcaught+1)*20) + (1 + random(10));

                        SendNearbyMessage(playerid, 20.0, COLOR_PURPLE, "%s �͡��ǹ�ѹ�索������о���Ҿǡ�ҨѺ%s��", ReturnRealName(playerid), FishNames[Fishcaught]);
                        SendClientMessageEx(playerid, COLOR_DARKGREEN, "�س�Ѻ%s %d �͹��", FishNames[Fishcaught], Fishlbs);

                        playerData[playerid][pFishes]+=Fishlbs;

                        if(playerData[playerid][pFishes] > 1000)
                        {
                            FishingPlace[playerid]=-1;
                            SendClientMessage(playerid, COLOR_DARKGREEN, "����Ҿ�����");
                            SendClientMessage(playerid, COLOR_DARKGREEN, "/unloadfish �ҡ�س��ͧ��â�»�Ңͧ�س");
                            return 1;
                        }
                    }
                    else SendClientMessage(playerid, COLOR_LIGHTRED, "�س����ҷ���������");

                }
            }
		}
		else {
			SendClientMessage(playerid, COLOR_LIGHTRED, "����ջ���ͺ �");
			SendClientMessage(playerid, COLOR_WHITE, "((�ô�� 6 �Թҷ������ /fish))");
		}
	}
	else
	{
	    SendClientMessage(playerid, COLOR_LIGHTRED, "�س�ѧ����鵡���");
	}
	return 1;
}

static IsABoat(model)
{
	switch (model) {
		case 430, 446, 452, 453, 454, 472, 473, 484, 493, 595: return 1;
	}
	return 0;
}